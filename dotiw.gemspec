# dotiw.gemspec
# -*- encoding: utf-8 -*-

$:.unshift File.join(File.dirname(__FILE__), 'lib') unless $:.include? File.join(File.dirname(__FILE__), 'lib')
require 'dotiw/version'

Gem::Specification.new do |s|
  s.name = 'dotiw'
  s.version = DOTIW::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.authors = ["Ryan Bigg"]
  s.date = %q{2010-12-23}
  s.description = "Better distance_of_time_in_words for Rails"
  s.summary = "Better distance_of_time_in_words for Rails"
  s.email = "radarlistener@gmail.com"

  s.add_dependency "actionpack", "~> 3"
  
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rspec", "~> 2.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

