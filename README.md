# Kenji

Kenji is a lightweight backend framework for Ruby.


## Rationale

Kenji believes that a traditional web application should be divided into two
parts: an client application running in the browser (HTML/JS/CSS), and
a backend API with which it communicates. Kenji is the backend side of the
equation, while the front-end architecture is left up to the user. (Popular
options are [backbone][] and [spine][].)

[backbone]: http://documentcloud.github.com/backbone/
[spine]: http://spinejs.com/

Kenji believes that in order to keep clean and organized code, routes should be
defined inline with their code.

Kenji believes that an app should be usable as a library from scripts or from
the command line. An app should be automatable and testable.

Lastly, Kenji is opinionated, but only about things that directly pertain to
routing and code architecture. Kenji believes in being a ligthweight module
that only solves the problem it focuses on. Everything else is left up to the
user. (ORM, data store, web server, message queue, front-end framework,
deployment process, etc.)


### Routing

Kenji wants you to organize your code into logical units of code, aka.
controllers. The controllers will automatically be selected based on the url
requested, and the rest of the route is defined inline in the controller, with
a domain-specific-language.

The canonical Hello World example for the URL `/hello/world` in Kenji would
look like this, in `controller/hello.rb`:

```ruby
class HelloController < Kenji::Controller
  get '/world' do
    {hello: :world}
  end
end
```

A more representative example might be:

```ruby
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
```


### Data Transport

JSON is used as the singular data transport for Kenji. Requests are assumed to
have:

    Content-Type: application/json; charset=utf-8
    Accept: application/json; charset=utf-8


## Usage

Getting started with Kenji could not be any easier. All it takes is a few lines
and a terminal:

    $ gem install kenji
    $ kenji init app_name; cd app_name
    $ rackup                    # launch the webserver

And already, your app is ready to go:

    $ curl http://localhost:9292/hello/world
    {"hello":"world"}


## Requirements & Assumptions

- Requires RubyGems and Bundler.
- Requires Rack ~> 1.5.3.
- Requires Ruby >= 1.9.3.


## Changelog

#### 1.2.1

- `respond_raw` now takes a second optional argument for additional headers.
- Fix bug with `kenji.header`

#### 1.2.0

- A new `exception_in_body` option (defaults to false) defines whether options
  are returned to the HTTP response instead of the default “Something went
  wrong...”
- `kenji init` no longer generates a useless binary.
- Internally, lots of style and best practices refactors.

#### 1.1.2

- The `respond_raw` method allows responding with raw data, instead of the
  default which serializes the response as a JSON object.
- Supports PATCH requests natively.
- Remove support for `auto_cors`. Instead of having Kenji implement it
  automatically, use a middleware like [Rack::Cors][rack-cors] which does
  a better job than the barebones implementation in Kenji does.

[rack-cors]: https://github.com/cyu/rack-cors

#### 1.1.1

- No longer catching ArgumentErrors when calling the block for a route. This
  fixes a bug where Kenji incorrectly responds with a 404 when the block is
  passed the wrong number of arguments.
- Fixed logic for matching a pass. the path now must match the pass exactly
  whereas before the pass would match if any subset of the path matched the
  pass.

#### 1.1

- Kenji::App is a simply wrapper that can and should be used in `config.ru`
  files. It avoids the need to wrap the Kenji initialization in a lambda.
- Kenji's stderr is now configurable as an option.
- The new option `catch_exceptions` (default true) configures whether Kenji
  will automatically rescue and log exceptions.
- The root path argument to initializing Kenji is now deprecated, and replaced
  with the `directory` named option. It is only necessary to set this when not
  using a `root_controller`.

#### 1.0

- ? TODO: fill me in

#### 0.7

- Pass can now contain variables, that get set as @ivars on the controller.
  Thanks @nicotaing.
- Accessors for `response_headers`

#### 0.6.5

- Automatically handle CORS / Access-Control.
- Use throw / catch instead of raise / rescue for control flow.

#### Before TODO: figure out when

- `before` command.
- specs
- passing

## Still to do

- The auto-generated project template should be updated.
- The controller naming convention should not contain a 'Controller' suffix.
- Route multiple URLs for the same route?

