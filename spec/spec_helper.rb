# encoding: utf-8
require 'rubygems'
$:.unshift(File.join(File.dirname(__FILE__), "../lib"))

require 'action_controller'
require 'active_support'
require 'dotiw'
require 'spec'

# Define time zone before loading, just like in the real world
zone = "UTC"
Time.zone = zone

I18n.load_path << Dir[File.join(File.dirname(__FILE__), "translations", "*")]
I18n.locale = :en

# bootstraping the plugin through init.rb
# tests how it would load in a real application
load File.dirname(__FILE__) + "/../rails/init.rb"
