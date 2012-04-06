require 'rubygems'
require 'bundler/setup'
require 'rack'
require "#{File.dirname(__FILE__)}/kenji/kenji"

# use Rack::ShowExceptions

app = proc do |env|
  Kenji::Kenji.new(env, File.dirname(__FILE__)).call
end
run app
