
require File.expand_path(File.dirname(__FILE__)+'/child.rb')

class ParentController < Kenji::Controller

  pass '/child', ChildController

  get '/hello' do
    {status: 200, hello: :world}
  end
end
