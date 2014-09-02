# encoding: utf-8

require 'i18n'

require 'active_support/dependencies/autoload'
require 'active_support/concern'
require 'active_support/ordered_hash'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/string/conversions'

require 'action_view/helpers/capture_helper'
require 'action_view/helpers/date_helper'
require 'action_view/helpers/number_helper'
require 'action_view/helpers/sanitize_helper'
require 'action_view/helpers/text_helper'

require 'dotiw'

Time.zone = 'UTC'
I18n.load_path.clear
I18n.load_path << Dir[File.join(File.dirname(__FILE__), "translations", "*")]
I18n.locale = :en
