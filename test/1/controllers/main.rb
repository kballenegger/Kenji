
class MainController < Kenji::Controller

  get '/hello' do
    {status: 200, hello: :world}
  end
end
