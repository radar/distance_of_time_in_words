# encoding: utf-8

ROOT_PATH = File.join(File.dirname(__FILE__), '..')
$:.unshift ROOT_PATH unless $:.include? ROOT_PATH

# Files that are usually required by Rails, but in a testing context will not be.
require 'erb'

require 'active_support/all'

require 'action_view/context'
require 'action_view/helpers'

require 'init' # require dotiw through init (like a plugin would)

Time.zone = 'UTC'
I18n.load_path.clear
I18n.load_path << Dir[File.join(File.dirname(__FILE__), "translations", "*")]
I18n.locale = :en
