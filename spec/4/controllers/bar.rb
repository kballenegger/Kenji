require File.expand_path('../pass.rb', __FILE__)

class BarController < Kenji::Controller
  get '/' do
    { :foo_id => @foo_id }
  end

  put '/:bar_id' do |bar_id|
    { :bar_id => bar_id, :foo_id => @foo_id }
  end

  pass '/passed', PassController

  fallback do
    kenji.respond(1337, '404')
  end
end
