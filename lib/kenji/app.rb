
module Kenji
  
  # Kenji::App is a simple wrapper class that helps avoid the awkward wrapping
  # in a lambda typically necessary for using Kenji as a Rack app. Instead,
  # simply do the following:
  #
  #   run Kenji::App.new(directory: Dir.getwd)
  #
  # Any options passed will also be forwarded to Kenji.
  #
  # Kenji::App has one instance for the app, unlike Kenji::Kenji which has one
  # instance per request.
  #
  class App

    def initialize(opts={})
      @opts = opts
    end

    def call(env)
      Kenji.new(env, @opts).call
    end
  end
end
