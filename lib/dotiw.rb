# encoding: utf-8

module DOTIW
  autoload :VERSION, 'dotiw/version'
  autoload :TimeHash, 'dotiw/time_hash'
end # DOTIW

module ActionView
  module Helpers
    module DateHelper
      alias_method :old_distance_of_time_in_words, :distance_of_time_in_words

      def distance_of_time_in_words_hash(from_time, to_time, options = {})
        from_time = from_time.to_time if !from_time.is_a?(Time) && from_time.respond_to?(:to_time)
        to_time   = to_time.to_time   if !to_time.is_a?(Time)   && to_time.respond_to?(:to_time)

        DOTIW::TimeHash.new((from_time - to_time).abs, from_time, to_time, options).to_hash
      end

      def distance_of_time(seconds, options = {})
        display_time_in_words DOTIW::TimeHash.new(seconds).to_hash, options
      end

      def distance_of_time_in_words(from_time, to_time, include_seconds = false, options = {})
        return old_distance_of_time_in_words(from_time, to_time, include_seconds, options) if options.delete(:vague)
        hash = distance_of_time_in_words_hash(from_time, to_time, options)
        display_time_in_words(hash, include_seconds, options)
      end

      def distance_of_time_in_percent(from_time, current_time, to_time, options = {})
        options[:precision] ||= 0
        distance = to_time - from_time
        result = ((current_time - from_time) / distance) * 100
        number_with_precision(result, options).to_s + "%"
      end

      private
        def display_time_in_words(hash, include_seconds = false, options = {})
          options.symbolize_keys!
          I18n.locale = options[:locale] if options[:locale]
          translation_scope  = options.delete(:translation_scope)

          time_measurements = ActiveSupport::OrderedHash.new
          time_measurements[:years]   = I18n.t(:years,   :scope => translation_scope, :default => "years")
          time_measurements[:months]  = I18n.t(:months,  :scope => translation_scope, :default => "months")
          time_measurements[:weeks]   = I18n.t(:weeks,   :scope => translation_scope, :default => "weeks")
          time_measurements[:days]    = I18n.t(:days,    :scope => translation_scope, :default => "days")
          time_measurements[:hours]   = I18n.t(:hours,   :scope => translation_scope, :default => "hours")
          time_measurements[:minutes] = I18n.t(:minutes, :scope => translation_scope, :default => "minutes")
          time_measurements[:seconds] = I18n.t(:seconds, :scope => translation_scope, :default => "seconds")

          hash.delete(time_measurements[:seconds]) if !include_seconds && hash[time_measurements[:minutes]]

          # Remove all the values that are nil or excluded. Keep the required ones.
          time_measurements.delete_if do |measure, key|
            hash[key].nil? || hash[key].zero? || (!options[:except].nil? && options[:except].include?(key)) ||
              (options[:only] && !options[:only].include?(key))
          end

          options.delete(:except)
          options.delete(:only)

          output = []

          time_measurements = Hash[*time_measurements.first] if options.delete(:highest_measure_only)

          time_measurements.each do |measure, key|
            name = options[:singularize] == :always || hash[key].between?(-1, 1) ? key.singularize : key
            output += options[:spaceless] ? ["#{hash[key]}#{name}"] : ["#{hash[key]} #{name}"]
          end

          options.delete(:spaceless)
          options.delete(:singularize)

          # maybe only grab the first few values
          if options[:precision]
            output = output[0...options[:precision]]
            options.delete(:precision)
          end

          output.to_sentence(options)
        end
    end # DateHelper
  end # Helpers
end # ActionView
