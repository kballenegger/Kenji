require 'json'
require 'kenji/controller'
require 'kenji/string_extensions'
require 'rack'

module Kenji
  class Kenji

    attr_reader :env, :root

    # Setting `kenji.status = 203` will affect the status code of the response.
    attr_accessor :status
    # Exceptions will be printed here, and controllers are expected to log to
    # this IO buffer:
    attr_accessor :stderr

    # Methods for rack!

    # Constructor...
    #
    def initialize(env, root)
      @headers = {
        'Content-Type' => 'application/json'
      }
      @status = 200
      @root = File.expand_path(root) + '/'
      @stderr = $stderr
      @env = env
    end

    # This method does all the work!
    #
    def call
      path = @env['PATH_INFO']
      
      # deal with static files
      static = "#{@root}public#{path}"
      return Rack::File.new("#{@root}public").call(@env) if File.file?(static)


      # new routing code
      segments = path.split('/')
      segments = segments.drop(1) if segments.first == ''       # discard leading /'s empty segment
      segments.unshift('')

      acc = ''; out = '', success = false
      while head = segments.shift
        acc = "#{acc}/#{head}"
        if controller = controller_for(acc)                     # if we have a valid controller 
          begin
            method = @env['REQUEST_METHOD'].downcase.to_sym
            subpath = '/'+segments.join('/')
            out = controller.call(method, subpath).to_json
          rescue KenjiRespondControlFlowInterrupt => e
            out = e.response
          end
          success = true
          break
        end
      end
      
      return response_404 unless success

      [@status, @headers, [out]]
    rescue Exception => e
      @stderr.puts e.inspect                                    # log exceptions
      e.backtrace.each {|b| @stderr.puts "  #{b}" }
      response_500
    end

    # 500 error
    def response_500
      [500, @headers, [{status: 500, message: 'Something went wrong...'}.to_json]]
    end

    # 404 error
    def response_404
      [404, @headers, [{status: 404, message: 'Not found!'}.to_json]]
    end



    # Methods for users!


    # Sets one or multiple headers, as named arametres. eg.
    # 
    #   kenji.header 'Content-Type' => 'hello/world'
    #
    def header(hash={})
      hash.each do |key, value|
        @headers[key] = value
      end
    end

    # Fetch (and cache) the json input to the request
    # Return a Hash
    #
    def input_as_json
      return @json_input if @json_input
      require 'json'
      raw = @env['rack.input'].read if @env['rack.input']
      begin
        return @json_input = JSON.parse(raw)
      rescue JSON::ParserError
      end if raw
      {} # default return value
    end
    
    # Respond to the request
    #
    def respond(code, message, hash={})
      @status = code
      response = {            # default structure. TODO: figure out if i really want to keep this 
        :status => code,
        :message => message
      }
      hash.each { |k,v| response[k]=v }
      raise KenjiRespondControlFlowInterrupt.new(response.to_json)
    end



    # Private methods
    private

    # Will attempt to fetch the controller, and verify that it is a implements call 
    #
    def controller_for(subpath)
      subpath = '/_' if subpath == '/'
      path = "#{@root}controllers#{subpath}.rb"
      return nil unless File.exists?(path)
      require path
      controller_name = subpath.split('/').last.sub(/^_/, 'Root')
      controller_class = Object.const_get(controller_name.to_s.to_camelcase+'Controller')
      return unless controller_class.method_defined?(:call) && controller_class.instance_method(:call).arity == 2 # ensure protocol compliance
      controller = controller_class.new
      controller.kenji = self if controller.respond_to?(:kenji=)
      return controller if controller
      nil # default return value
    end
    
  end
  

  class KenjiRespondControlFlowInterrupt < StandardError
    attr_accessor :response
    def initialize(response)
        @response = response
    end
  end # early exit containing a response
end

