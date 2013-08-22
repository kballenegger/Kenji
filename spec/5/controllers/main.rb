module Spec5
  class MainController < Kenji::Controller
    get '/' do
      { :foo => 'bar' }
    end

    get '/path' do
      { :baz => 'bar' }
    end

    get '/foo/:foo_id/:bar_id' do |foo_id|
    	{ :baz => 'bar' }
    end

    get "/bar/:foo_id/:bar_id" do |foo_id, bar_id, baz_id|
    	{ :baz => 'bar' }
    end

    get "/foobar/:foo_id/:bar_id" do |foo_id, bar_id|
    	{ :foo => foo_id, :bar => bar_id }
    end
  end
end
