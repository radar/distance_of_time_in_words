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
      from_time = normalize_distance_of_time_argument_to_time(from_time)
      to_time = normalize_distance_of_time_argument_to_time(to_time)
      from_time, to_time = to_time, from_time if from_time > to_time

      if include_seconds_or_options.is_a?(Hash)
        options = include_seconds_or_options
      else
        options = options.dup
        options[:include_seconds] ||= !!include_seconds_or_options
      end

      return distance_of_time(to_time.to_i, options) if from_time.to_i == 0

      options = options_with_scope(options)
      hash = distance_of_time_in_words_hash(from_time, to_time, options)
      _display_time_in_words(hash, options)
    end

    def time_ago_in_words(from_time, include_seconds_or_options = {})
      distance_of_time_in_words(from_time, Time.current, include_seconds_or_options)
    end

    private

    # How many of each measure is necessary to round up to one of the next-largest measure. Note
    # that for simplicity of implementation, we only check one measure when seeing if we should
    # round up. This means that rounding up days to weeks, for instance, cannot draw the line at 3
    # days and 12 hours, but instead either 3 or 4 (whole) days. Let's not even talk about weeks
    # rounding up to months.
    ROUNDING_THRESHOLDS = {
      seconds: 30,
      minutes: 30,
      hours: 12,
      days: 4,
      weeks: 2,
      months: 6,
      years: Float::INFINITY,
    }

    ROLLUP_THRESHOLDS = {
      seconds: 60,
      minutes: 60,
      hours: 24,
      days: 7,
      weeks: 4, # !!!
      months: 12,
      years: Float::INFINITY,
    }

    def normalize_distance_of_time_argument_to_time(value)
      if value.is_a?(Numeric)
        Time.at(value)
      elsif value.respond_to?(:to_time)
        value.to_time
      else
        raise ArgumentError, "#{value.inspect} can't be converted to a Time value"
      end
    end

    def options_with_scope(options)
      if options.key?(:compact)
        options.merge(scope: DOTIW::DEFAULT_I18N_SCOPE_COMPACT)
      else
        options
      end
    end

    def _display_time_in_words(hash, options = {})
      hash = hash.dup

      options = options.reverse_merge(
        include_seconds: false
      ).symbolize_keys!

      discarded_hash = {}

      include_seconds = options.delete(:include_seconds)
      discarded_hash[:seconds] = hash.delete(:seconds) if !include_seconds && hash[:minutes]

      options[:except] = Array.wrap(options[:except]).map!(&:to_sym) if options[:except]
      options[:only] = Array.wrap(options[:only]).map!(&:to_sym) if options[:only]

      DOTIW::TimeHash::TIME_FRACTIONS.each do |fraction|
        if options[:except]&.include?(fraction) || (options[:only] && !options[:only].include?(fraction))
          discarded_hash[fraction] = hash.delete fraction
        end
      end

      hash.delete_if { |key, value| value.nil? || value.zero? }
      discarded_hash.delete_if { |key, value| value.nil? || value.zero? }

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

      options.delete(:except)
      options.delete(:only)

      highest_measures = _compute_highest_measures! options
      if highest_measures
        high_entries, low_entries = hash.to_a.partition.with_index { |_, index| index < highest_measures[:max] }
        hash = high_entries.to_h
        discarded_hash.merge! low_entries.to_h

        _maybe_round! hash, discarded_hash, highest_measures[:remainder]
      end

      phrases = []
      I18n.with_options locale: options[:locale], scope: i18n_scope do |locale|
        phrases = hash.map { |key, value| locale.t(key, count: value) }
      end

      options[:words_connector] ||= I18n.translate :"#{i18n_scope}.words_connector",
                                                   default: :'support.array.words_connector',
                                                   locale: options[:locale]
      options[:two_words_connector] ||= I18n.translate :"#{i18n_scope}.two_words_connector",
                                                       default: :'support.array.two_words_connector',
                                                       locale: options[:locale]
      options[:last_word_connector] ||= I18n.translate :"#{i18n_scope}.last_word_connector",
                                                       default: :'support.array.last_word_connector',
                                                       locale: options[:locale]

      phrases.to_sentence(options.except(:accumulate_on, :compact))
    end

    def _compute_highest_measures!(options)
      highest_measures = options.delete(:highest_measures)
      highest_measures = 1 if options.delete(:highest_measure_only)
      highest_measures = { max: highest_measures } if highest_measures.is_a?(Integer)
      highest_measures = highest_measures.reverse_merge(max: 1, remainder: :floor) if highest_measures

      highest_measures
    end

    def _maybe_round!(hash, discarded_hash, remainder)
      smallest_measure_index = DOTIW::TimeHash::TIME_FRACTIONS.index hash.to_a.last[0]
      smallest_measure = DOTIW::TimeHash::TIME_FRACTIONS[smallest_measure_index]

      case remainder
      when :floor
        # Nothing to do.
      when :ceiling
        # We already filtered out zeroes, so non-empty also means non-zero.
        if !discarded_hash.empty?
          hash[smallest_measure] += 1
          _rollup! hash, smallest_measure_index
        end
      when :round
        # If our smallest measure is already the smallest possible measure, there is no next
        # smallest measure to inspect to see if we need to round up.
        return if smallest_measure_index == 0

        next_smallest_measure = DOTIW::TimeHash::TIME_FRACTIONS[smallest_measure_index - 1]
        if discarded_hash.fetch(next_smallest_measure, 0) >= ROUNDING_THRESHOLDS[next_smallest_measure]
          hash[smallest_measure] += 1
          _rollup! hash, smallest_measure_index
        end
      else
        raise ArgumentError, "unrecognized remainder value #{remainder.inspect}"
      end
    end

    def _rollup!(hash, smallest_measure_index)
      DOTIW::TimeHash::TIME_FRACTIONS[smallest_measure_index..-1].each_with_index do |fraction, index|
        if hash.fetch(fraction, 0) >= ROLLUP_THRESHOLDS[fraction]
          hash.delete fraction
          next_fraction = DOTIW::TimeHash::TIME_FRACTIONS[smallest_measure_index + index + 1]
          hash[next_fraction] = hash.fetch(next_fraction, 0) + 1
        else
          break
        end
      end
    end
  end
end
