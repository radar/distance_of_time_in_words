# frozen_string_literal: true

module ActionView
  module Helpers
    module DateHelper
      alias_method :_distance_of_time_in_words, :distance_of_time_in_words
      alias_method :_time_ago_in_words, :time_ago_in_words

      include DOTIW::Methods

      def distance_of_time_in_words(from_time, to_time = 0, include_seconds_or_options = {}, options = {})
        return _distance_of_time_in_words(from_time, to_time, options) if options.delete(:vague)
        DOTIW::Methods.distance_of_time_in_words(from_time, to_time, include_seconds_or_options, options)
      end

      def distance_of_time_in_percent(from_time, current_time, to_time, options = {})
        options[:precision] ||= 0
        distance = to_time - from_time
        result = ((current_time - from_time) / distance) * 100
        number_with_precision(result, options).to_s + '%'
      end
    end # DateHelper
  end # Helpers
end # ActionView
