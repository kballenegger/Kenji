class BarController < Kenji::Controller
  get '/' do
    { :foo_id => @foo_id }
  end

  put '/:bar_id' do |bar_id|
    { :bar_id => bar_id, :foo_id => @foo_id }
  end
end
