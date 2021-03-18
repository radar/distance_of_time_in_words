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
  DEFAULT_I18N_SCOPE_COMPACT = :'datetime.dotiw_compact'

  def init_i18n!
    I18n.load_path.unshift(*locale_files)
    I18n.reload!
  end

  def languages
    @languages ||= (locale_files.map { |path| path.split(%r{[/.]})[-2].to_sym })
  end

  def locale_files
    files 'dotiw/locale', '*.yml'
  end

  protected

  def files(directory, ext)
    Dir[File.join File.dirname(__FILE__), directory, ext]
  end
end

DOTIW.init_i18n!

begin
  require 'action_view'
  require_relative 'dotiw/action_view/helpers/date_helper'
rescue LoadError
  # TODO: don't rely on exception
end
