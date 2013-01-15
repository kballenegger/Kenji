
require File.expand_path(File.dirname(__FILE__)+'/child.rb')

class RootController < Kenji::Controller
  get '/' do
    {status: 200, controller_used: :root}
  end
  pass '/child', ChildController
end
