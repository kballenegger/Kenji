*Project is still very much work in progress. This is not production ready!*


# Kenji

Kenji is a lightweight MVC web framework for Ruby.


## Ideas

Some of the main ideas behind Kenji include:

- No defining routes: convention trumps configuration here. Automatic URL mapping /:controller/:action/:params.
- The backend is a JSON-only API, the front-end is a html/js wrapper. Front-end architecture is up to the user.
- Lightweight: Kenji only takes care of routing and overall app architecture. Everything else is up to the user.
- The app should be usable from the command-line and as a library the same as if it were used as an HTTP app to make unit testing and scripting much easier.


# Usage

Getting started with Kenji could not be any easier. All it takes is a few lines and a terminal:

    $ gem install kenji         # (once kenji is on the rubygems main source)
    $ kenji-init app_name; cd app_name
    $ rackup                    # launch the webserver

And already, your app is ready to go:

    $ curl http://localhost:9292/
    {"hello":"world"}


## Todos

Big architural decisions:

- Figure out meaning of HTTP method.

    Possibility: use a DSL inside classes for http methods?

    ```ruby
    class Main
        get :index do
            respond { hello: 'world' }
        end
    end
    ```

- `kenji init` will simply create the base directory structure for a kenji app
- Figure out best format for configuration files

Misc stuff:

- Figure out out to serve this up in a gem.
- Figure out serving static files.
- Switch to API-only model, json only.


## Requirements & Assumptions

- Requires rubygems and bundler.
- Requires Ruby 1.8.7 or 1.9.
