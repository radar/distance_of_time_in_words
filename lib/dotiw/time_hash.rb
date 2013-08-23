# encoding: utf-8

module DOTIW
  class TimeHash
    TIME_FRACTIONS = [:seconds, :minutes, :hours, :days, :months, :years]

    attr_accessor :distance, :smallest, :largest, :from_time, :to_time, :options

    def initialize(distance, from_time = nil, to_time = nil, options = {})
      self.output     = {}
      self.options    = options
      self.distance   = distance
      self.from_time  = from_time || Time.now
      self.to_time    = to_time   || (self.from_time + self.distance.seconds)
      self.smallest, self.largest = [self.from_time, self.to_time].minmax

      I18n.locale = options[:locale] if options[:locale]

      build_time_hash
    end

    def to_hash
      output
    end

    private
      attr_accessor :options, :output

      def build_time_hash
        if accumulate_on = options.delete(:accumulate_on)
          return build_time_hash if accumulate_on == :years
          TIME_FRACTIONS.index(accumulate_on).downto(0) { |i| self.send("build_#{TIME_FRACTIONS[i]}") }
        else
          while distance > 0
            if distance < 1.minute
              build_seconds
            elsif distance < 1.hour
              build_minutes
            elsif distance < 1.day
              build_hours
            elsif distance < 28.days
              build_days
            else # greater than a month
              build_years_months_days
            end
          end
        end

        output
      end

      def build_seconds
        output[Helper::i18n_t(:seconds)] = distance.to_i
        self.distance = 0
      end

      def build_minutes
        output[Helper::i18n_t(:minutes)], self.distance = distance.divmod(1.minute)
      end

      def build_hours
        output[Helper::i18n_t(:hours)], self.distance = distance.divmod(1.hour)
      end

      def build_days
        output[Helper::i18n_t(:days)], self.distance = distance.divmod(1.day)
      end

      def build_months
        build_years_months_days

        if (years = output.delete(Helper::i18n_t(:years))) > 0
          output[Helper::i18n_t(:months)] += (years * 12)
        end
      end

      def build_years_months_days
        months = (largest.year - smallest.year) * 12 + (largest.month - smallest.month)
        years, months = months.divmod(12)

        days = largest.day - smallest.day

        # Will otherwise incorrectly say one more day if our range goes over a day.
        days -= 1 if largest.hour < smallest.hour

        if days < 0
          # Convert the last month to days and add to total
          months -= 1
          last_month = largest.advance(:months => -1)
          days += Time.days_in_month(last_month.month, last_month.year)
        end

        if months < 0
          # Convert a year to months
          years -= 1
          months += 12
        end

        output[Helper::i18n_t(:years)]   = years
        output[Helper::i18n_t(:months)]  = months
        output[Helper::i18n_t(:days)]    = days

        total_days, self.distance = (from_time - to_time).abs.divmod(1.day)
      end
  end # TimeHash
end # DOTIW
