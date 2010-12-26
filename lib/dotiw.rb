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

      def display_time_in_words(hash, include_seconds = false, options = {})
        options.symbolize_keys!
        hash.delete(:seconds) if !include_seconds && hash[:minutes]
        I18n.with_options :locale => options[:locale] do |locale|
          # Remove all the values that are nil.
          time_measurements = [locale.t(:years, :default => "years"),
                               locale.t(:months, :default => "months"),
                               locale.t(:weeks, :default => "weeks"),
                               locale.t(:days, :default => "days"),
                               locale.t(:hours, :default => "hours"),
                               locale.t(:minutes, :default => "minutes"),
          locale.t(:seconds, :default => "seconds")].delete_if do |key|
            hash[key].nil? || hash[key].zero? ||
              # Remove the keys that we don't want.
              (!options[:except].nil? && options[:except].include?(key)) ||
              # keep the keys we only want.
              (options[:only] && !options[:only].include?(key))
          end

          options.delete(:except)
          options.delete(:only)
          output = []
          time_measurements.each do |key|
            name = hash[key] > 1 ? key : key.singularize
            output += ["#{hash[key]} #{name}"]
          end

          # maybe only grab the first few values
          if options[:precision]
            output = output[0...options[:precision]]
            options.delete(:precision)
          end

          output.to_sentence(options)
        end
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
    end # DateHelper
  end # Helpers
end # ActionView
