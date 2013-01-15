
require 'rack'
require 'rack/test'
require File.expand_path(File.dirname(__FILE__)+'/../lib/kenji.rb')
require 'rspec'


# NOTE: these tests make use of the controllers defined in test/controllers.


describe Kenji do

  include Rack::Test::Methods

  def app
    lambda do |env|
      Kenji::Kenji.new(env, File.dirname(__FILE__)).call
    end
  end


  it 'should return "null" for unknown routes' do
    get '/sdlkjhb'
    last_response.body.should == 'null'
  end

  it 'should route a GET call to a defined get call' do
    get '/parent/hello'
    expected_response = {status: 200, hello: :world}.to_json
    last_response.body.should == expected_response
  end

  it 'should pass routing down to child controllers' do
    get '/parent/child/foo'
    expected_response = {status: 200, foo: :bar}.to_json
    last_response.body.should == expected_response
  end
end
