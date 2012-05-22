*Project is still very much work in progress. This is not production ready!*


# Kenji

Kenji is a lightweight MVC web framework for Ruby.


## Ideas

Some of the main ideas behind Kenji include:

- Routes are defined where it makes sense, not in a config file. More on this below.
- The backend is a JSON-only API, the front-end is a html/js wrapper. Front-end architecture is up to the user.
- Lightweight: Kenji only takes care of routing and overall app architecture. Everything else (data layer, ORM, web server, etc.) is up to the user.
- The app should be usable from the command-line and as a library the same as if it were used as an HTTP app to make unit testing, scripting and development much easier.

### Routing

Kenji wants you to organize your code into logical units of code, aka. controllers. The controllers will automatically be selected based on the url requested, and the rest of the route is defined inline in the controller, with a domain-specific-language.

The caconical Hello World example for the URL `/hello/world` in kenji would look like this, in `controller/hello.rb`:

````ruby
class HelloController < Kenji::Controller
    get '/world' do
        {hello: :world}
    end
end
````

A more representative example might be:

````ruby
class UserController < Kenji::Controller

    # ...

    get '/:id/friends' do |id|
        # list friends for id
    end

    post '/:id/friend/:id' do |id, friend_id|
        # add connection from user id to friend_id
    end

    delete '/:id/friend/:id' do |id, friend_id|
        # delete connection from user id to friend_id
    end
end
````


## Usage

Getting started with Kenji could not be any easier. All it takes is a few lines and a terminal:

    $ gem install kenji         # (once kenji is on the rubygems main source)
    $ kenji-init app_name; cd app_name
    $ rackup                    # launch the webserver

And already, your app is ready to go:

    $ curl http://localhost:9292/
    {"hello":"world"}


## Todos


- Figure out best format for configuration files. # note: JSON sounds pretty damn good. vijson will make that much friendlier
- Figure out serving static files.
- Switch to API-only model, json only.
- Anything with a TODO comment


## Requirements & Assumptions

- Requires rubygems and bundler.
- Requires Ruby 1.9.
