# encoding: utf-8

require 'i18n'

require 'active_support/all'
require 'action_view'
require 'dotiw'

Time.zone = 'UTC'
I18n.load_path.clear
I18n.load_path << Dir[File.join(File.dirname(__FILE__), "translations", "*")]
I18n.locale = :en

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec
  config.order = 'random'

  config.include ActionView::Helpers::DateHelper
  config.include ActionView::Helpers::TextHelper
  config.include ActionView::Helpers::NumberHelper
end