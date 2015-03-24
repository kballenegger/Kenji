
class MainController < Kenji::Controller

  get '/crasher' do
    raise 'kaboom!'
  end

end
