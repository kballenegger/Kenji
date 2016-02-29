
module Kenji
  class Controller

    # use the reader freely to grab the kenji object
    attr_accessor :kenji

    # Routes below will accept routes in the format, eg.:
    #
    #     /hello/:id/children
    #
    # Can contain any number of :id, but must be in their own url segment.
    # Colon-prefixed segments become variables, passed onto the given block as
    # arguments. The name given to the variable is irrelevant, and is thrown
    # away: /hello/:/children is equivalent to the example above. Given block
    # must have correct arity.

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

    # Route PATCH
    def self.patch(path, &block)
      route(:patch, path, &block)
    end

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
    # Note: this works by building a tree for the path, each node being a path
    # segment or variable segment, and the leaf @action being the block
    #
    def self.route(*methods, path, &block)

      # bind the block to self as an instance method, so its context is correct
      define_method(:_tmp_route_action, &block)
      block = instance_method(:_tmp_route_action)
      remove_method(:_tmp_route_action)

      # store the block for each method
      methods.each do |method|

        node = ((@routes ||= {})[method] ||= {})
        segments = path.split('/')
        # discard leading /'s empty segment
        segments = segments.drop(1) if segments.first == ''
        # lazily create tree
        segments.each do |segment|
          # discard :variable name
          segment = ':' if segment =~ /^:/
          node = (node[segment.to_sym] ||= {})
        end
        # store block as leaf in @action
        node[:@action] = block
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
      # discard leading /'s empty segment
      segments = segments.drop(1) if segments.first == ''
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
      # discard leading /'s empty segment
      segments = segments.drop(1) if segments.first == ''

      # check for passes
      node = self.class.passes
      remaining_segments = segments.dup

      f = fetch_passes(node, remaining_segments)

      if f[:match] && f[:controller]
        instance = f[:controller].new
        instance.kenji = kenji if instance.respond_to?(:kenji=)
        f[:variables].each do |k, v|
          instance.instance_variable_set(:"@#{k}", v)
        end
        # 404s don't return
        catch(:KenjiPass404) do
          return instance.call(method, f[:remaining_segments].join('/'))
        end
      end

      # regular routing
      node = self.class.routes[method] || {}
      variables = []
      searching = true
                              # traverse tree to find
      segments.each do |segment|
        if searching && node[segment.to_sym]
          # attempt to move down to the plain text segment
          node = node[segment.to_sym]
        elsif searching && node[:':']
          # attempt to find a variable segment
          node = node[:':']
          # either we've found a variable, or the `unless` below will trigger
          variables << segment
        else
          # route failed to match variable or segment node so attempt fallback
          return attempt_fallback(path)
        end
      end
      # the block is stored in the @action leaf
      if node && (action = node[:@action])
        return action.bind(self).call(*variables)
      else # or, fallback if necessary store the block for each method
        return attempt_fallback(path)
      end
    end

    def attempt_fallback(path)
      if respond_to?(:fallback)
        if self.class.instance_method(:fallback).arity == 1
          return fallback(path)
        else
          return fallback
        end
      else
        throw(:KenjiPass404)
      end
    end


    # Utility method: this can be used to log to stderr cleanly.
    #
    def log(*args)
      kenji.stderr.puts(*args)
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

    def fetch_passes(node, segments)
      variables = {}
      match = false

      while (e = segments.shift)
        # return false unless node
        key = node.keys.first
        if (match = key.to_s.match(/^\:(\w+)/))
          node = node[key.to_sym]
          variables[match[1].to_sym] = e
          match = true
        else
          # if there is no match it should not pass
          break unless (match = node.key?(e.to_sym))
          node = node[e.to_sym]
        end

        break if node[:@controller]
      end

      {
        match:              match,
        variables:          variables,
        controller:         node[:@controller],
        remaining_segments: segments,
      }
    end
  end
end
