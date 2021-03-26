# frozen_string_literal: true

module DOTIW
  module Methods
    extend self

    def distance_of_time_in_words_hash(from_time, to_time, options = {})
      from_time = from_time.to_time if !from_time.is_a?(Time) && from_time.respond_to?(:to_time)
      to_time = to_time.to_time if !to_time.is_a?(Time) && to_time.respond_to?(:to_time)

      DOTIW::TimeHash.new(nil, from_time, to_time, options).to_hash
    end

    def distance_of_time(seconds, options = {})
      options = options_with_scope(options).reverse_merge(
        include_seconds: true
      )
      options.delete(:compact)
      _display_time_in_words DOTIW::TimeHash.new(seconds, nil, nil, options).to_hash, options
    end

    def distance_of_time_in_words(from_time, to_time = 0, include_seconds_or_options = {}, options = {})
      raise ArgumentError, "nil can't be converted to a Time value" if from_time.nil? || to_time.nil?

      if include_seconds_or_options.is_a?(Hash)
        options = include_seconds_or_options
      else
        options = options.dup
        options[:include_seconds] ||= !!include_seconds_or_options
      end
      return distance_of_time(from_time, options) if to_time == 0

      options = options_with_scope(options)
      hash = distance_of_time_in_words_hash(from_time, to_time, options)
      _display_time_in_words(hash, options)
    end

    def time_ago_in_words(from_time, include_seconds_or_options = {})
      distance_of_time_in_words(from_time, Time.current, include_seconds_or_options)
    end

    private

    def options_with_scope(options)
      if options.key?(:compact)
        options.merge(scope: DOTIW::DEFAULT_I18N_SCOPE_COMPACT)
      else
        options
      end
    end

    def _display_time_in_words(hash, options = {})
      options = options.reverse_merge(
        include_seconds: false
      ).symbolize_keys!

      include_seconds = options.delete(:include_seconds)
      hash.delete(:seconds) if !include_seconds && hash[:minutes]

      options[:except] = Array.wrap(options[:except]).map!(&:to_sym) if options[:except]
      options[:only] = Array.wrap(options[:only]).map!(&:to_sym) if options[:only]

      # Remove all the values that are nil or excluded. Keep the required ones.
      hash.delete_if do |key, value|
        value.nil? || value.zero? ||
          options[:except]&.include?(key) ||
          (options[:only] && !options[:only].include?(key))
      end

      i18n_scope = options.delete(:scope) || DOTIW::DEFAULT_I18N_SCOPE
      if hash.empty?
        fractions = DOTIW::TimeHash::TIME_FRACTIONS
        fractions &= options[:only] if options[:only]
        fractions -= options[:except] if options[:except]

        I18n.with_options locale: options[:locale], scope: i18n_scope do |locale|
          # e.g. try to format 'less than 1 days', fallback to '0 days'
          return locale.translate :less_than_x,
                                  distance: locale.translate(fractions.first, count: 1),
                                  default: locale.translate(fractions.first, count: 0)
        end
      end

      output = []
      I18n.with_options locale: options[:locale], scope: i18n_scope do |locale|
        output = hash.map { |key, value| locale.t(key, count: value) }
      end

      options.delete(:except)
      options.delete(:only)
      highest_measures = options.delete(:highest_measures)
      highest_measures = 1 if options.delete(:highest_measure_only)
      output = output[0...highest_measures] if highest_measures

      options[:words_connector] ||= I18n.translate :"#{i18n_scope}.words_connector",
                                                   default: :'support.array.words_connector',
                                                   locale: options[:locale]
      options[:two_words_connector] ||= I18n.translate :"#{i18n_scope}.two_words_connector",
                                                       default: :'support.array.two_words_connector',
                                                       locale: options[:locale]
      options[:last_word_connector] ||= I18n.translate :"#{i18n_scope}.last_word_connector",
                                                       default: :'support.array.last_word_connector',
                                                       locale: options[:locale]

      output.to_sentence(options.except(:accumulate_on, :compact))
    end
  end
end
