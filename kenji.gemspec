$LOAD_PATH.push(File.expand_path('../lib', __FILE__))
require 'kenji/version'

Gem::Specification.new do |s|
  s.name        = 'kenji'
  s.version     = Kenji::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Kenji'
  s.description = 'A lightweight Ruby web framework.'
  s.authors     = ['Kenneth Ballenegger']
  s.email       = ['kenneth@ballenegger.com']
  s.homepage    = 'https://github.com/kballenegger/kenji'

  s.add_dependency 'json'
  s.add_dependency 'rack', '~> 1.5.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
