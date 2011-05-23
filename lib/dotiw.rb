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
          translation_scope = options.delete(:translation_scope)

          # Remove all the values that are nil or excluded. Keep the required ones.
          hash.delete_if do |key, value|
            value.nil? || value.zero? || (options[:except] && options[:except].include?(key)) ||
              (options[:only] && !options[:only].include?(key))
          end

          options.delete(:except)
          options.delete(:only)
          
          time_measurements = ActiveSupport::OrderedHash.new
          
          DOTIW::TimeHash::TIME_FRACTIONS.reverse.each do |key|
            measure = I18n.t(key, :scope => translation_scope, :default => key.to_s)
            time_measurements[key] = measure if hash[measure] || (options[:show_zeros] && !time_measurements.empty?)
          end
          
          options.delete(:show_zeros)
          
          time_measurements.delete(:seconds) if !include_seconds && hash[time_measurements[:minutes]]
          time_measurements = Hash[*time_measurements.first] if options.delete(:highest_measure_only)
          
          output = []

          time_measurements.each do |measure, key|
            value = hash[key] || 0
            name = options[:singularize] == :always || [-1, 1].include?(value) ? key.singularize : key
            output += options[:spaceless] ? ["#{value}#{name}"] : ["#{value} #{name}"]
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
