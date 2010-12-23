# encoding: utf-8

DOTIW_LIB_PATH = File.join(File.dirname(__FILE__), '..', 'lib')

$:.unshift DOTIW_LIB_PATH unless $:.include? DOTIW_LIB_PATH
$:.unshift File.dirname(__FILE__)

require 'i18n'
require 'active_support/i18n'
require 'active_support/core_ext/time/zones'
require 'ruby-debug'

Time.zone = 'UTC'

I18n.load_path.clear
I18n.load_path << Dir[File.join(File.dirname(__FILE__), "translations", "*")]
I18n.locale = :en