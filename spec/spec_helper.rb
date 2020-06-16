ROOT_PATH = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift ROOT_PATH unless $LOAD_PATH.include? ROOT_PATH

# Files that are usually required by Rails, but in a testing context will not be.
require 'erb'

require 'active_support/all'
require 'action_view'

require 'dotiw'

Time.zone = 'UTC'

I18n.load_path << Dir[File.join(File.dirname(__FILE__), 'translations', '*')]
I18n.locale = :en
