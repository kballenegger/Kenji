require File.expand_path('../bar.rb', __FILE__)
require File.expand_path('../pass.rb', __FILE__)

class MainController < Kenji::Controller
  get '/' do
    { :foo => 'bar' }
  end

  pass '/foo/:foo_id/pass', PassController
  pass '/foo/:foo_id/bar', BarController
end