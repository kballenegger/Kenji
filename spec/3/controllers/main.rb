
class MainController < Kenji::Controller

  #before do
    #kenji.respond(302, 'redirect...')
  #end

  get '/hello' do
    {status: 200, hello: :world}
  end
end
