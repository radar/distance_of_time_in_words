require 'rubygems'
require 'rake'
require 'bundler'

require 'rspec/core'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

begin
  [:spec, :rcov].each { |task|
    RSpec::Core::RakeTask.new(task) do |t|
      t.rspec_opts = %w(-fs --color)
    end
  }
  task :default => :spec
rescue LoadError
  raise 'RSpec could not be loaded. Run `bundle install` to get all development dependencies.'
end
