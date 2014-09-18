# dotiw.gemspec
# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require 'dotiw/version'

Gem::Specification.new do |s|
  s.name = 'dotiw'
  s.version = DOTIW::VERSION

  s.authors = ["Ryan Bigg"]
  s.date = %q{2010-12-23}
  s.description = "Better distance_of_time_in_words for Rails"
  s.summary = "Better distance_of_time_in_words for Rails"
  s.email = "radarlistener@gmail.com"

  s.add_dependency "actionpack", ">= 3"
  s.add_dependency "i18n"
  
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "tzinfo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

