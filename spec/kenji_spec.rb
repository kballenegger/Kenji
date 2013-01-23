
require 'rack'
require 'rack/test'
require 'rspec'
require 'rspec/mocks'

require 'kenji'


# NOTE: these tests make use of the controllers defined in test/controllers.

def app_for(path)
  lambda do |env|
    kenji = Kenji::Kenji.new(env, File.dirname(__FILE__)+'/'+path)
    kenji.stderr = double(puts: nil)
    kenji.call
  end
end

describe Kenji::Kenji, 'expected reponses' do
  include Rack::Test::Methods

  context '1' do
    def app; app_for('1'); end


    it 'should return 404 for unknown routes (no controller)' do
      get '/sdlkjhb'
      expected_response = {status: 404, message: 'Not found!'}.to_json
      last_response.body.should == expected_response
      last_response.status.should == 404
    end

    it 'should return 404 for unknown routes (no route on valid controller)' do
      get '/main/sdlkjhb'
      expected_response = {status: 404, message: 'Not found!'}.to_json
      last_response.body.should == expected_response
      last_response.status.should == 404
    end

    it 'should return 500 for exceptions' do
      get '/main/crasher'
      expected_response = {status: 500, message: 'Something went wrong...'}.to_json
      last_response.body.should == expected_response
      last_response.status.should == 500
    end

    it 'should route a GET call to a defined get call' do
      get '/main/hello'
      expected_response = {status: 200, hello: :world}.to_json
      last_response.body.should == expected_response
    end

    [:post, :put, :delete].each do |method|

      it "should route a #{method.to_s.upcase} to a defined #{method.to_s} call" do
        send(method, '/main')
        expected_response = {status: 1337}.to_json
        last_response.body.should == expected_response
      end
    end

    it 'should return "null" for unsupported methods' do
      post '/main/hello'
      expected_response = {status: 404, message: 'Not found!'}.to_json
      last_response.body.should == expected_response
      last_response.status.should == 404
    end

    it 'should use throw / catch to respond immediately with kenji.respond' do
      get '/main/respond'
      expected_response = {status: 123, message: 'hello'}.to_json
      last_response.body.should == expected_response
      last_response.status.should == 123
    end

    it 'should automatically allow CORS for simple requests' do
      header 'Origin', 'foo'
      get '/main/hello'
      last_response.header['Access-Control-Allow-Origin'].should == 'foo'
    end

    it 'should automatically allow CORS for complex requests' do
      header 'Origin', 'foo'
      header 'Access-Control-Request-Headers', 'Bar'
      options '/main/hello'
      last_response.header['Access-Control-Allow-Origin'].should == 'foo'
      last_response.header['Access-Control-Allow-Methods'].should == 'OPTIONS, GET, POST, PUT, DELETE'
      last_response.header['Access-Control-Allow-Headers'].should == 'Bar'
    end

  end

  context '2' do
    def app; app_for('2'); end

    it 'should use root controller' do
      get '/'
      expected_response = {status: 200, controller_used: :root}.to_json
      last_response.body.should == expected_response
    end

    it 'should pass routing down to child controllers' do
      get '/child/foo'
      expected_response = {status: 200, foo: :bar}.to_json
      last_response.body.should == expected_response
    end

  end

  context '3' do
    def app; app_for('3'); end

    it 'should call before block' do
      get '/before/hello'
      expected_response = {status: 302, message: 'redirect...'}.to_json
      last_response.body.should == expected_response
      last_response.status.should == 302
    end

  end

end
