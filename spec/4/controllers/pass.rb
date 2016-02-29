class PassController < Kenji::Controller
  get '/' do
    { :foo_id => @foo_id }
  end

  get '/test' do
    { :test => 'hello!' }
  end

  put '/:pass_id' do |pass_id|
    { :pass_id => pass_id, :foo_id => @foo_id }
  end
end
