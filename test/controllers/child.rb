

class ChildController < Kenji::Controller

  get '/foo' do
    {status: 200, foo: :bar}
  end
end
