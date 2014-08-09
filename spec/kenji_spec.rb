
require 'rack'
require 'rack/test'
require 'rspec'
require 'rspec/mocks'

require 'kenji'


# NOTE: these tests make use of the controllers defined in test/controllers.

def app_for(path, opts={})
  lambda do |env|
    kenji = Kenji::Kenji.new(env, File.dirname(__FILE__)+'/'+path, opts)
    kenji.stderr = double(puts: nil)
    kenji.call
  end
end

describe Kenji::Kenji, 'expected responses' do
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

    [:post, :put, :delete, :patch].each do |method|

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

    it 'should use respond immediately with kenji.respond_raw' do
      get '/main/respond-raw'
      expected_response = 'hello raw'
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it 'should use respond immediately with kenji.respond_raw is passed an IO' do
      get '/main/respond-io'
      expected_response = 'hello io'
      last_response.body.should == expected_response
      last_response.status.should == 123
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

    it 'should not match subsets of the route' do
      get 'something/child/foo'
      last_response.status.should == 404
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

  context '4' do
    def app; app_for('4'); end

    it "should use main controller" do
      get '/main'
      expected_response = { :foo => 'bar' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should use pass controller and use get endpoint" do
      get '/main/foo/foo_id/pass'
      expected_response = { :foo_id => 'foo_id' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should use pass controller and use put endpoint" do
      put '/main/foo/foo_id/pass/pass_id'
      expected_response = { :pass_id => 'pass_id', :foo_id => 'foo_id' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should use pass controller and use get endpoint" do
      get '/main/foo/foo_id/bar'
      expected_response = { :foo_id => 'foo_id' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should use pass controller and use put endpoint" do
      put '/main/foo/foo_id/bar/bar_id'
      expected_response = { :bar_id => 'bar_id', :foo_id => 'foo_id' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end
  end

  context '5' do
    before do
      require File.expand_path('./5/controllers/main.rb', File.dirname(__FILE__))
    end

    def app; app_for('5', root_controller: Spec5::MainController); end

    it "should use main controller for /" do
      get '/'
      expected_response = { :foo => 'bar' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should use main controller for /path" do
      get '/path'
      expected_response = { :baz => 'bar' }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should 404 on main controller" do
      put '/main/foo/foo_id/pass/pass_id'
      last_response.status.should == 404
    end

    it "should pass variables to blocks" do
      get "/foobar/foo_id/bar_id"
      expected_response = { :foo => "foo_id", :bar => "bar_id" }.to_json
      last_response.body.should == expected_response
      last_response.status.should == 200
    end

    it "should throw ArgumentError when there are too many arguments" do
      get "foo/foo_id/bar_id"
      last_response.status.should == 500
    end

    it "should throw ArgumentError when there are too few arguments" do
      get "bar/foo_id/bar_id"
      last_response.status.should == 500
    end
  end
  
  # TODO: Write unit tests for :catch_exceptions option.
  # TODO: Write unit tests for Kenji::App
  # TODO: Write unit tests for new root directory behavior.

end
