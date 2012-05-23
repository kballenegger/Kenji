*Project is still actively in development.*


# Kenji

Kenji is a lightweight backend framework for Ruby.


## Rationale

Kenji believes that a traditional web application should be divided into two parts: an client application running in the browser (HTML/JS/CSS), and a backend API with which it communicates. Kenji is the backend side of the equation, while the front-end architecture is left up to the user. (Popular options are [backbone][] and [spine][].)

[backbone]: http://documentcloud.github.com/backbone/
[spine]: http://spinejs.com/

Kenji believes that in order to keep clean and organized code, routes should be defined inline with their code.

Kenji believes that an app should be usable as a library from scripts or from the command line. An app should be automatable and testable.

Lastly, Kenji is opinionated, but only about things that directly pertain to routing and code architecture. Kenji believes in being a ligthweight module that only solves the problem it focuses on. Everything else is left up to the user. (ORM, data store, web server, message queue, front-end framework, deployment process, etc.)


### Routing

Kenji wants you to organize your code into logical units of code, aka. controllers. The controllers will automatically be selected based on the url requested, and the rest of the route is defined inline in the controller, with a domain-specific-language.

The canonical Hello World example for the URL `/hello/world` in kenji would look like this, in `controller/hello.rb`:

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


### Data Transport

JSON is used as the singular data transfort for Kenji. Requests are assumed to have:

    Content-Type: application/json; charset=utf-8
    Accept: application/json; charset=utf-8


## Usage

Getting started with Kenji could not be any easier. All it takes is a few lines and a terminal:

    $ gem install kenji         # (once kenji is on the rubygems main source)
    $ kenji-init app_name; cd app_name
    $ rackup                    # launch the webserver

And already, your app is ready to go:

    $ curl http://localhost:9292/hello/world
    {"hello":"world"}


## Requirements & Assumptions

- Requires rubygems and bundler.
- Requires Ruby 1.9.
