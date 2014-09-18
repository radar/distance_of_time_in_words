# encoding: utf-8

require 'i18n'

# Rails hacks
if defined?(ActionView::Helpers)
  require 'dotiw/action_view_ext/helpers/date_helper'
end

module DOTIW
  extend self
  
  autoload :VERSION, 'dotiw/version'
  autoload :TimeHash, 'dotiw/time_hash'

  DEFAULT_I18N_SCOPE = :'datetime.dotiw'

  def init_i18n
    I18n.load_path.unshift(*locale_files)
    I18n.reload!
  end

protected
  # Returns all locale files shipped with library
  def locale_files
    Dir[File.join(File.dirname(__FILE__), 'dotiw', 'locale', '**/*')]
  end
end # DOTIW

DOTIW.init_i18n
