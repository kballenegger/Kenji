
module Kenji
  class Controller
  
    # Routes below will accept routes in the format, eg.:
    #     /hello/:id/children
    # Can contain any number of :id, but must be in their own url segment.
    # Colon-prefixed segments become variables, passed onto the given block as arguments.
    # The name given to the variable is irrelevant, and is thrown away: /hello/:/children is equivalent to the example above. 
    # Given block must have correct arity.
    
    # Route GET
    def self.get(path, &block)
      self.route(:get, path, &block)
    end

    # Route POST
    def self.post(path, &block)
      self.route(:post, path, &block)
    end

    # Route PUT
    def self.put(path, &block)
      self.route(:put, path, &block)
    end

    # Route DELETE
    def self.delete(path, &block)
      self.route(:delete, path, &block)
    end

    # TODO: figure out whether I want PATCH, OPTIONS, HEAD

    # Route all methods for given path
    def self.all(path, &block)
      self.route(:get, :post, :put, :delete, path, &block)
    end

    def self.fallback(&block)
      define_method(:fallback, block)
      nil # void method
    end

    # Route a given path to the correct block, for any given methods
    #
    # Note: this works by building a tree for the path,
    # each node being a path segment or variable segment, and the leaf @action being the block
    
    def self.route(*methods, path, &block)
      methods.each do |method|
        node = ((@routes ||= {})[method] ||= {})
        segments = path.split('/')
        segments = segment.drop(1) if segments.first == ''      # discard leading /'s empty segment
        segments.each do |segment|                              # lazily create tree
          segment = ':' if segment =~ /^:/                      # discard :variable name
          node = (node[segment.to_sym] ||= {})
        end
        node[:@action] = block                                  # store block as leaf in @action
      end
      nil # void method
    end

    
    # Most likely only used by Kenji itself.
    # Override to implement your own routing, if you'd like.
    def call(method, path)
      segments = path.split('/')
      segments = segment.drop(1) if segments.first == ''      # discard leading /'s empty segment
      node = @routes[method]
      variables = []
      segments.each do |segment|                              # traverse tree to find 
        node = node[segment.to_sym] if node[segment.to_sym]   
        unless node = node[segment.to_sym]                    # attempt to move down to the plain text segment
          node = node[:':']                                   # attempt to find a variable segment
          variables << segment                                # either we've found a variable, or the `unless` below will trigger
        end
        unless node                                           # fallback if a valid node cannot be found
          return fallback if respond_to? :fallback            # and return
        end
      end
      if action = node[:@action]                              # the block is stored in the @action leaf
        return action.call(*variables)
      else
        if respond_to? :fallback
          if self.instance_method(:fallback).arity == 1
            return fallback(path)
          else
            return fallback
          end
        end
      end
    end
  end
end
