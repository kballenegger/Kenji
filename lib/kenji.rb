# Bare-bones, ruby implementation of Paraglide
# require 'stringio'

# TODO: rewrite this file!

module Kenji
  class Kenji

    attr_accessor :controller, :action
    attr_reader :env, :root

    def initialize env, root
      @headers = {
        'Content-Type' => 'application/json'
      }
      @status = 200
      root = File.expand_path root
      @root = root + '/'
      @env = env
      load? 'lib/hooks'
      @hook_object = Object.const_get(:Hooks).new if Object.const_defined? :Hooks
      @hooks = {}
      load_lib 'string_extensions'
      hook :after_initialize
    end

    def header hash
      hash.each do |key, value|
        @headers[key] = value
      end
    end

    def call

      out = buffer do
        
        next unless route # parse the routing
        
        # Loading our controller on the fly!
        if File.exists? "#{@root}controllers/#{@controller}.rb"

          if controller = controller_for(@controller)
            # Send message, if it supports it. Fall back to :index, or fail.
            if controller.respond_to? @action.to_sym
              dispatch_action controller, @action, @params
            elsif controller.respond_to? :index
              dispatch_action controller, 'index', [@action]+@params
            else
              # TODO: Fall back to main controller.
              error "Could not call controller/action."
            end
          else
            error "Could not load controller."
          end
        else
          error "Could not find appropriate controller."
        end
      end

      [@status, @headers, [out]]
    end

    def load path
      require @root + path
    end

    def load? path
      path += '.rb' unless path =~ /\.rb$/
      load path if File.exists? @root + path
    end

    def hook name, &block
      if block_given?
        @hooks[name] = block
      else
        dispatch_hook name
      end
    end

    def controller_for controller
      # Load the file, if it exists, and its controller object. Assume correct naming.
      require "#{@root}controllers/#{controller}.rb"
      controller_class = Object.const_get(controller.to_s.to_camelcase+'Controller')
      if controller_class.instance_method(:initialize).arity == 1
        controller = controller_class.new self
      else
        controller = controller_class.new
      end
      return controller if controller
    end
    
    # Deprecated
    def input_raw
      return @raw_input if @raw_input
      return unless @env
      @raw_input = @env['rack.input'].read if @env['rack.input']
    end
    
    def input_as_json
      return @json_input if @json_input
      require 'json'
      raw = input_raw
      begin
        return @json_input = JSON.parse(raw)
      rescue JSON::ParserError => e
        return nil
      end if raw
    end
    
    # Deprecated
    def input_as_form
      return unless raw = input_raw
      pairs = raw.split('&')
      require 'uri'
      pairs.map! do |p|
        p.split('=').map! { |v| URI.unescape v }
      end
      Hash[pairs]
    end
    
    # Responding to the request and rendering
    
    def respond code, message, hash={}
      # TODO: respond w/ status code as well
      case @extension
      when :html
        puts message
        # Deprecated
      when :json
        response = {
          :status => code,
          :message => message
        }
        hash.each { |k,v| response[k]=v }
        puts response.to_json        
      end
      raise EarlyExit
    end
    
    # Private methods
    private
    def route
      path = @env['PATH_INFO']

      # static
      static = "#{@root}public#{path}"
      if File.file? static
        # note: super inefficient, fix
        file = File.open(static, 'r')
        data = ""
        while line = file.gets
          data += line
        end
        print data
        return false
      end
      
      segments = path.split '/'
      segments.shift if segments.first == ''
      segments.pop if segments.last == ''
      if segments.last =~ /\.[a-z]+$/
        last = segments.pop
        regex = Regexp.new(/^(.+)\.([a-z]+)$/)
        if matches = regex.match(last)
          last = matches[1]
          extension = matches[2]
        end
        segments = segments.push last
      end

      controller = segments[0]
      action = segments[1].gsub(/^_/, '') unless segments[1].nil?     # don't allow leading _, to allow for "private" public methods
      params = segments[2..segments.length]

      controller = 'main' unless controller
      action = 'index' unless action
      params = [] unless params
      extension = 'json' unless extension

      @controller, @action, @params, @extension = controller.to_sym, action.to_sym, params, extension.to_sym
      return true
    end

    def buffer *args, &block
      old_stdout = $stdout
      $stdout = StringIO.new
      yield args
      out = $stdout
      $stdout = old_stdout
      out.rewind
      out.read
    end

    def dispatch_action controller, action, params
      return unless controller.respond_to? action.to_sym

      case arity = controller.method(action.to_sym).arity
      when 0
        controller.send action.to_sym
      when 1
        controller.send action.to_sym, self
      when (3..1.0/0)
        controller.send action.to_sym, self, *params[(0..arity-1)]
      when -1
        controller.send action.to_sym, *params
      when (-1.0/0..-2)
        controller.send action.to_sym, self, *params
      end
    rescue EarlyExit => e
      return # controller exited early, it's all good
    end

    def dispatch_hook name
      if block = @hooks[name]
        if block.arity == 1
          block.call self
        else
          block.call
        end
      end
      if @hook_object && name
        if @hook_object.method(name).arity == 1
          @hook_object.send name, self
        else
          @hook_object.send name
        end
      end
    end

    def error message
      respond 400, message
    end

    def load_lib name
      require File.expand_path File.dirname(__FILE__) + '/kenji/' + name
    end
  end
  
  class EarlyExit < StandardError; end # lets us exit out of a kenji call, like `exit`
end
