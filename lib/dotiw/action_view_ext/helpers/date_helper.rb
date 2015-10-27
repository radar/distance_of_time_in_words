module ActionView
  module Helpers
    module DateHelper
      alias_method :old_distance_of_time_in_words, :distance_of_time_in_words

      def distance_of_time_in_words_hash(from_time, to_time, options = {})
        from_time = from_time.to_time if !from_time.is_a?(Time) && from_time.respond_to?(:to_time)
        to_time = to_time.to_time if !to_time.is_a?(Time) && to_time.respond_to?(:to_time)

        DOTIW::TimeHash.new(nil, from_time, to_time, options).to_hash
      end

      def distance_of_time(seconds, options = {})
        options[:include_seconds] ||= true
        display_time_in_words DOTIW::TimeHash.new(seconds, nil, nil, options).to_hash, options
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
        distance_of_time_in_words(from_time, Time.current, include_seconds_or_options)
      end

      private
      def display_time_in_words(hash, options = {})
        options.reverse_merge!(
            :include_seconds => false
        ).symbolize_keys!

        include_seconds = options.delete(:include_seconds)
        hash.delete(:seconds) if !include_seconds && hash[:minutes]

        options[:except] = Array.wrap(options[:except]).map!(&:to_sym) if options[:except]
        options[:only] = Array.wrap(options[:only]).map!(&:to_sym) if options[:only]

        # Remove all the values that are nil or excluded. Keep the required ones.
        hash.delete_if do |key, value|
          value.nil? || value.zero? ||
              (options[:except] && options[:except].include?(key)) ||
              (options[:only] && !options[:only].include?(key))
        end

        i18n_scope = options.delete(:scope) || DOTIW::DEFAULT_I18N_SCOPE
        if hash.empty?
          fractions = DOTIW::TimeHash::TIME_FRACTIONS
          fractions = fractions & options[:only] if options[:only]
          fractions = fractions - options[:except] if options[:except]

          I18n.with_options :locale => options[:locale], :scope => i18n_scope do |locale|
            # e.g. try to format 'less than 1 days', fallback to '0 days'
            return locale.translate :less_than_x,
                                    :distance => locale.translate(fractions.first, :count => 1),
                                    :default => locale.translate(fractions.first, :count => 0)
          end
        end

        output = []
        I18n.with_options :locale => options[:locale], :scope => i18n_scope do |locale|
          output = hash.map { |key, value| locale.t(key, :count => value) }
        end

        options.delete(:except)
        options.delete(:only)
        highest_measures = options.delete(:highest_measures)
        highest_measures = 1 if options.delete(:highest_measure_only)
        if highest_measures
          output = output[0...highest_measures]
        end

        options[:words_connector] ||= I18n.translate :'datetime.dotiw.words_connector',
                                                     :default => :'support.array.words_connector',
                                                     :locale => options[:locale]
        options[:two_words_connector] ||= I18n.translate :'datetime.dotiw.two_words_connector',
                                                         :default => :'support.array.two_words_connector',
                                                         :locale => options[:locale]
        options[:last_word_connector] ||= I18n.translate :'datetime.dotiw.last_word_connector',
                                                         :default => :'support.array.last_word_connector',
                                                         :locale => options[:locale]

        output.to_sentence(options)
      end
    end # DateHelper
  end # Helpers
end # ActionView
