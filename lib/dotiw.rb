# frozen_string_literal: true

require_relative 'dotiw/core'

begin
  require 'action_view'
  require_relative 'dotiw/action_view/helpers/date_helper'
rescue LoadError
  # TODO: don't rely on exception
end
