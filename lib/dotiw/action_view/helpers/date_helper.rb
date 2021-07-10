# frozen_string_literal: true

module ActionView
  module Helpers
    module DateHelper
      alias _distance_of_time_in_words distance_of_time_in_words
      alias _time_ago_in_words time_ago_in_words

      include DOTIW::Methods

      def distance_of_time_in_words(from_time, to_time = 0, include_seconds_or_options = {}, options = {})
        options = merge_options(include_seconds_or_options, options)
        return _distance_of_time_in_words(from_time, to_time, options.except(:vague)) if options[:vague]

        DOTIW::Methods.distance_of_time_in_words(from_time, to_time, options.except(:vague))
      end

      def distance_of_time_in_words_to_now(to_time = 0, include_seconds_or_options = {}, options = {})
        options = merge_options(include_seconds_or_options, options)
        return _distance_of_time_in_words(Time.now, to_time, options.except(:vague)) if options[:vague]

        DOTIW::Methods.distance_of_time_in_words(Time.now, to_time, options.except(:vague))
      end

      def distance_of_time_in_percent(from_time, current_time, to_time, options = {})
        options[:precision] ||= 0
        options = options_with_scope(options)
        distance = to_time - from_time
        result = ((current_time - from_time) / distance) * 100
        number_with_precision(result, options).to_s + '%'
      end

      private
      def merge_options(include_seconds_or_options, options)
        merged_options = options.dup
        if include_seconds_or_options.is_a?(Hash)
          merged_options.merge!(include_seconds_or_options)
        else
          merged_options.merge!(include_seconds: !!include_seconds_or_options)
        end
      end

    end
  end
end
