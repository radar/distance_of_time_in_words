# frozen_string_literal: true

require 'i18n'

require 'active_support'
require 'active_support/core_ext'

module DOTIW
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :VERSION, 'dotiw/version'
    autoload :TimeHash, 'dotiw/time_hash'
    autoload :Methods, 'dotiw/methods'
  end

  extend self

  DEFAULT_I18N_SCOPE = :'datetime.dotiw'

  def init_i18n!
    I18n.load_path.unshift(*locale_files)
    I18n.reload!
  end

  protected

  # Returns all locale files shipped with library
  def locale_files
    Dir[File.join(File.dirname(__FILE__), 'dotiw', 'locale', '**/*')]
  end
end # DOTIW

DOTIW.init_i18n!

begin
  require 'action_view'
  require_relative 'dotiw/action_view/helpers/date_helper'
rescue LoadError
  # TODO: don't rely on exception
end
