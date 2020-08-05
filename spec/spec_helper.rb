# frozen_string_literal: true

ROOT_PATH = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift ROOT_PATH unless $LOAD_PATH.include? ROOT_PATH

require 'dotiw'

if defined?(ActionView)
  require 'action_controller'
end

Time.zone = 'UTC'

I18n.locale = :en
