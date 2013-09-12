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
        options[:include_seconds] ||= true
        display_time_in_words DOTIW::TimeHash.new(seconds).to_hash, options
      end

      def distance_of_time_in_words(from_time, to_time = 0, include_seconds_or_options = {}, options = {})
        if include_seconds_or_options.is_a?(Hash)
          options = include_seconds_or_options
        else
          options[:include_seconds] ||= !!include_seconds_or_options
        end
        return distance_of_time(from_time, options) if to_time == 0
        return old_distance_of_time_in_words(from_time, to_time, options) if options.delete(:vague)
        hash = distance_of_time_in_words_hash(from_time, to_time, options)
        display_time_in_words(hash, options)
      end

      def distance_of_time_in_percent(from_time, current_time, to_time, options = {})
        options[:precision] ||= 0
        distance = to_time - from_time
        result = ((current_time - from_time) / distance) * 100
        number_with_precision(result, options).to_s + "%"
      end

      alias_method :old_time_ago_in_words, :time_ago_in_words

      def time_ago_in_words(from_time, include_seconds_or_options = {})
        distance_of_time_in_words(from_time, Time.now, include_seconds_or_options)
      end

    private
      def display_time_in_words(hash, options = {})
        options.reverse_merge!(
          :include_seconds => false
        ).symbolize_keys!

        include_seconds = options.delete(:include_seconds)
        hash.delete(:seconds) if !include_seconds && hash[:minutes]

        # Remove all the values that are nil or excluded. Keep the required ones.
        hash.delete_if do |key, value|
          value.nil? || value.zero? || (!options[:except].nil? && options[:except].include?(key.to_s)) ||
            (options[:only] && !options[:only].include?(key.to_s))
        end

        options.delete(:except)
        options.delete(:only)

        highest_measures = options.delete(:highest_measures)
        highest_measures = 1 if options.delete(:highest_measure_only)
        if highest_measures
          keys = [:years, :months, :days, :hours, :minutes, :seconds]
          first_index = keys.index(hash.first.first)
          keys = keys[first_index, highest_measures]
          hash.delete_if { |key, value| !keys.include?(key) }
        end

        output = []
        I18n.with_options :locale => options[:locale], :scope => options.delete(:scope) do |locale|
          output = hash.map { |key, value| "#{value.to_s} #{locale.t(key, :count => value, :default => key.to_s)}" }
        end

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
