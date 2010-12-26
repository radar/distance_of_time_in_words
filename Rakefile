require 'rubygems'
require 'rake'
require 'bundler'
Bundler::GemHelper.install_tasks


begin
  require 'rspec/core/rake_task'
  [:spec, :rcov].each { |task| RSpec::Core::RakeTask.new(task) }
  task :default => :spec
rescue LoadError
  raise 'RSpec could not be loaded. Run `bundle install` to get all development dependencies.'
end