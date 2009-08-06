# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dotiw}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Bigg"]
  s.date = %q{2009-08-06}
  s.email = %q{radarlistener@gmail.com}
  s.files = ["Rakefile", "lib/dotiw.rb", "spec/dotiw_spec.rb", "spec/translations/en.yml", "spec/translations/es.yml", "spec/spec_helper.rb", "rails/init.rb", "README.markdown", "MIT-LICENSE"]
  s.homepage = %q{http://github.com/radar/dotiw}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Overrides distance_of_time_in_words to be better}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
