# frozen_string_literal: true

ROOT_PATH = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift ROOT_PATH unless $LOAD_PATH.include? ROOT_PATH

# Ruby 3.4 dropped concurrent-ruby's implicit require of logger, which older
# Rails versions rely on being already loaded, see https://github.com/rails/rails/issues/54271.
require 'logger'
require 'bundler'
Bundler.require

require 'dotiw'

# Loads Rails' own datetime.distance_in_words translations for non-English
# locales, needed by the vague: true option, which falls back to Rails'
# native distance_of_time_in_words instead of dotiw's own translations, see #44.
# Only present when the rails-i18n gem is in the Gemfile (see gemfiles/rails_8.1_i18n.gemfile).
if defined?(RailsI18n)
  I18n.load_path += Dir[File.join(Gem.loaded_specs['rails-i18n'].gem_dir, 'rails', 'locale', '*.yml')]
end

Time.zone = 'UTC'

I18n.locale = :en
