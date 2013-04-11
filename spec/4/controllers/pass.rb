class PassController < Kenji::Controller
  get '/' do
    { :foo_id => @foo_id }
  end

  put '/:pass_id' do |pass_id|
    { :pass_id => pass_id, :foo_id => @foo_id }
  end
end
