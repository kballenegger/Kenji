
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

  patch '/' do
    {status:1337}
  end

  get '/respond' do
    kenji.respond(123, 'hello')
    raise # never called
  end

  get '/respond-raw' do
    kenji.respond_raw('hello raw')
    raise # never called
  end

  get '/respond-io' do
    kenji.respond_raw(123, StringIO.new('hello io'))
    raise # never called
  end
end
