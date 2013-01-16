
module Kenji
  class Controller

    # use the reader freely to grab the kenji object
    attr_accessor :kenji
  
    # Routes below will accept routes in the format, eg.:
    #     /hello/:id/children
    # Can contain any number of :id, but must be in their own url segment.
    # Colon-prefixed segments become variables, passed onto the given block as arguments.
    # The name given to the variable is irrelevant, and is thrown away: /hello/:/children is equivalent to the example above. 
    # Given block must have correct arity.
    
    # Route GET
    def self.get(path, &block)
      route(:get, path, &block)
    end

    # Route POST
    def self.post(path, &block)
      route(:post, path, &block)
    end

    # Route PUT
    def self.put(path, &block)
      route(:put, path, &block)
    end

    # Route DELETE
    def self.delete(path, &block)
      route(:delete, path, &block)
    end

    # TODO: figure out whether I want PATCH, OPTIONS, HEAD

    # Route all methods for given path
    def self.all(path, &block)
      route(:get, :post, :put, :delete, path, &block)
    end

    def self.fallback(&block)
      define_method(:fallback, &block)
      nil # void method
    end

    # Route a given path to the correct block, for any given methods
    #
    # Note: this works by building a tree for the path,
    # each node being a path segment or variable segment, and the leaf @action being the block
    
    def self.route(*methods, path, &block)
      # bind the block to self as an instance method, so its context is correct
      define_method(:_tmp_route_action, &block)
      block = instance_method(:_tmp_route_action)
      remove_method(:_tmp_route_action)
      # store the block for each method
      methods.each do |method|
        node = ((@routes ||= {})[method] ||= {})
        segments = path.split('/')
        segments = segments.drop(1) if segments.first == ''     # discard leading /'s empty segment
        segments.each do |segment|                              # lazily create tree
          segment = ':' if segment =~ /^:/                      # discard :variable name
          node = (node[segment.to_sym] ||= {})
        end
        node[:@action] = block                                  # store block as leaf in @action
      end
      nil # void method
    end

    # This lets us pass the routing down to another controller for a sub-path.
    #
    #   class MyController < Kenji::Controller
    #     pass '/admin/*', AdminController
    #     # regular routes
    #   end
    #
    def self.pass(path, controller)
      node = (@passes ||= {})
      segments = path.split('/')
      segments = segments.drop(1) if segments.first == ''     # discard leading /'s empty segment
      segments.each do |segment|
        node = (node[segment.to_sym] ||= {})
        break if segment == '*'
      end
      node[:@controller] = controller
    end


    # This lets you define before blocks.
    #
    #   class MyController < Kenji::Controller
    #     before do
    #       # eg. ensure authentication, you can use kenji.respond in here.
    #     end
    #   end
    #   
    def self.before(&block)
      define_method(:_tmp_before_action, &block)
      block = instance_method(:_tmp_before_action)
      remove_method(:_tmp_before_action)
      (@befores ||= []) << block
    end

    
    # Most likely only used by Kenji itself.
    # Override to implement your own routing, if you'd like.
    #
    def call(method, path)

      self.class.befores.each {|b| b.bind(self).call }

      segments = path.split('/')
      segments = segments.drop(1) if segments.first == ''     # discard leading /'s empty segment

      # check for passes
      node = self.class.passes
      remaining_segments = segments.dup
      while s = remaining_segments.shift
        next unless node[s.to_sym]
        node = node[s.to_sym]
        break
      end
      if node[:@controller]
        instance = node[:@controller].new
        return instance.call(method, remaining_segments.join('/'))
      end

      # regular routing
      node = self.class.routes[method] || {}
      variables = []
      searching = true
      segments.each do |segment|                              # traverse tree to find 
        if searching && node[segment.to_sym]
          node = node[segment.to_sym]                         # attempt to move down to the plain text segment
        elsif searching && node[:':']
          node = node[:':']                                   # attempt to find a variable segment
          variables << segment                                # either we've found a variable, or the `unless` below will trigger
        else
          variables << segment                                # dump the remaining segments if we cannot drill down further
          searching = false
        end
      end
      if node && action = node[:@action]                      # the block is stored in the @action leaf
        begin
          return action.bind(self).call(*variables)
        rescue ArgumentError                                  # assuming argument error means route not defined
          return attempt_fallback(path)                       # TODO: might want to check arity instead
        end
      else                                                    # or, fallback if necessary store the block for each method
        return attempt_fallback(path)
      end
    end

    def attempt_fallback(path)
      if respond_to? :fallback
        if self.class.instance_method(:fallback).arity == 1
          return fallback(path)
        else
          return fallback
        end
      else
        kenji.respond(404, 'Not found!')
      end
    end

    private
    # Accessor for @routes
    def self.routes
      @routes || {}
    end
    def self.passes
      @passes || {}
    end
    def self.befores
      @befores || []
    end
  end
end

