module Spec5
  class MainController < Kenji::Controller
    get '/' do
      { :foo => 'bar' }
    end
    get '/path' do
      { :baz => 'bar' }
    end
  end
end
