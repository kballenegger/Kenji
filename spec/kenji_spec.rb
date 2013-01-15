
require 'rack'
require 'rack/test'
require 'rspec'

require 'kenji'


# NOTE: these tests make use of the controllers defined in test/controllers.

def app_for(path)
    lambda do |env|
      Kenji::Kenji.new(env, File.dirname(__FILE__)+'/'+path).call
    end
end

describe Kenji do

  include Rack::Test::Methods
  def app; app_for('1'); end


  it 'should return "null" for unknown routes' do
    get '/sdlkjhb'
    last_response.body.should == 'null'
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
    last_response.body.should == 'null'
  end

end

describe Kenji do
  include Rack::Test::Methods
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
