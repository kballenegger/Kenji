
class MainController < Kenji::Controller

  get '/hello' do
    {status: 200, hello: :world}
  end

  post '/' do
    {status:1337}
  end

  put '/' do
    {status:1337}
  end

  delete '/' do
    {status:1337}
  end
end
