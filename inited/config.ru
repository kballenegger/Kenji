require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'kenji'

# use Rack::ShowExceptions

run do |env|
  Kenji::Kenji.new(env, File.dirname(__FILE__)).call
end
