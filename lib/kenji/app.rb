
module Kenji
  
  # Kenji::App is a simple wrapper class that helps avoid the awkward wrapping
  # in a lambda typically necessary for using Kenji as a Rack app. Instead,
  # simply do the following:
  #
  #   app Kenji::App.new(File.dirname(__FILE__))
  #
  # Any options passed will also be forwarded to Kenji.
  #
  class App

    def initialize(path, opts={})
      @path = path
      @opts = opts
    end

    def call(env)
      Kenji::Kenji.new(env, @path, @opts).call
    end
  end
end
