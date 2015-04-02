require 'bundler'
Bundler::GemHelper.install_tasks
require 'rspec/core'
require 'rspec/core/rake_task'
task default: :spec
task test:    :spec
RSpec::Core::RakeTask.new(:spec)
