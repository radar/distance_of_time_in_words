# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'dotiw/version'

Gem::Specification.new do |s|
  s.name = 'dotiw'
  s.version = DOTIW::VERSION
  s.licenses = ['MIT']

  s.authors = ['Ryan Bigg', 'Lauran Jansen']
  s.description = "dotiw is a gem for Rails that overrides the
              default distance_of_time_in_words and provides
              a more accurate output. Do you crave accuracy
              down to the second? So do I. That's why I made
              this gem. - Ryan"
  s.summary = 'Better distance_of_time_in_words for Rails'
  s.email = ['radarlistener@gmail.com', 'github@lauranjansen.com']
  s.homepage = 'https://github.com/radar/distance_of_time_in_words'

  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'tzinfo', '~> 1.2.7'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
