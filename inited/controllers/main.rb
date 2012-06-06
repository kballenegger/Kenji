
class MainController < Kenji::Controller
  get '/index' do
    {hello: :world}
  end
end
