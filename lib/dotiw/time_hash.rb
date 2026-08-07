# frozen_string_literal: true

module DOTIW
  class TimeHash
    TIME_FRACTIONS = %i[seconds minutes hours days weeks months years].freeze

    attr_reader :distance, :smallest, :largest, :from_time, :to_time

    def initialize(distance, from_time, to_time = nil, options = {})
      @output     = {}
      @options    = options.dup
      @distance   = distance
      @from_time  = from_time || Time.current
      @to_time    = to_time   || (@to_time_not_given = true && @from_time + distance.seconds)
      @smallest, @largest = [@from_time, @to_time].minmax
      @to_time   += 1.hour if @to_time_not_given && smallest.dst? && !largest.dst?
      @to_time   -= 1.hour if @to_time_not_given && !smallest.dst? && largest.dst?
      @smallest, @largest = [@from_time, @to_time].minmax
      @distance ||= begin
        d = largest - smallest
        d -= 1.hour if smallest.dst? && !largest.dst?
        d += 1.hour if !smallest.dst? && largest.dst?
        d
      end

      build_time_hash
    end

    def to_hash
      output
    end

    private

    attr_reader :options, :output

    ONE_MINUTE = 1.minute.freeze
    ONE_HOUR = 1.hour.freeze
    ONE_DAY = 1.day.freeze
    ONE_WEEK = 7.days.freeze
    FOUR_WEEKS = 28.days.freeze

    def build_time_hash
      if (max_unit = options[:max_unit])
        build_max_unit(max_unit.to_sym)
      elsif accumulate_on = options[:accumulate_on]
        accumulate_on = accumulate_on.to_sym
        TIME_FRACTIONS.index(accumulate_on).downto(0) { |i| send("build_#{TIME_FRACTIONS[i]}") }
      else
        while distance > 0
          if distance < ONE_MINUTE
            build_seconds
          elsif distance < ONE_HOUR
            build_minutes
          elsif distance < ONE_DAY
            build_hours
          elsif distance < ONE_WEEK
            build_days
          elsif distance < FOUR_WEEKS
            build_weeks
          else # greater than a week
            build_years_months_weeks_days
          end
        end
      end

      output
    end

    def build_seconds
      output[:seconds] = distance.to_i
      @distance = 0
    end

    def build_minutes
      output[:minutes], @distance = distance.divmod(ONE_MINUTE.to_i)
    end

    def build_hours
      output[:hours], @distance = distance.divmod(ONE_HOUR.to_i)
    end

    def build_days
      output[:days], @distance = distance.divmod(ONE_DAY.to_i) unless output[:days]
    end

    def build_weeks
      output[:weeks], @distance = distance.divmod(ONE_WEEK.to_i) unless output[:weeks]
    end

    # Expresses the entire distance as a single number in the given unit, discarding
    # (flooring) any remainder smaller than that unit, unlike +accumulate_on+ which keeps
    # showing the smaller units below the target.
    def build_max_unit(unit)
      case unit
      when :seconds
        output[:seconds] = distance.to_i
      when :minutes
        output[:minutes] = (distance / ONE_MINUTE).floor
      when :hours
        output[:hours] = (distance / ONE_HOUR).floor
      when :days
        output[:days] = (distance / ONE_DAY).floor
      when :weeks
        output[:weeks] = (distance / ONE_WEEK).floor
      when :months
        output[:months] = whole_months_between(smallest, largest)
      when :years
        output[:years] = whole_years_between(smallest, largest)
      else
        raise ArgumentError, "unrecognized max_unit #{unit.inspect}"
      end

      @distance = 0
    end

    def whole_months_between(from, to)
      months = (to.year - from.year) * 12 + (to.month - from.month)
      months -= 1 if to.advance(months: -months) < from
      months
    end

    def whole_years_between(from, to)
      years = to.year - from.year
      years -= 1 if to.advance(years: -years) < from
      years
    end

    def build_months
      build_years_months_weeks_days

      if options[:accumulate_on]&.to_sym == :months && (years = output.delete(:years)) > 0
        output[:months] += (years * 12)
      end
    end

    def build_years
      build_years_months_weeks_days
    end

    def build_years_months_weeks_days
      months = (largest.year - smallest.year) * 12 + (largest.month - smallest.month)
      years, months = months.divmod(12)

      days = largest.day - smallest.day

      weeks, days = days.divmod(7)

      # Will otherwise incorrectly say one more day if our range goes over a day.
      days -= 1 if largest.hour < smallest.hour

      if days < 0
        # Convert a week to days and add to total
        weeks -= 1
        days += 7
      end

      if weeks < 0
        # Convert the last month to a week and add to total
        months -= 1
        last_month = largest.advance(months: -1)
        days_in_month = Time.days_in_month(last_month.month, last_month.year)
        weeks += days_in_month / 7
        days += days_in_month % 7
        if days >= 7
          days -= 7
          weeks += 1
        end

        if weeks == -1
          months -= 1
          weeks = 4
          days -= 4
        end
      end

      if months < 0
        # Convert a year to months
        years -= 1
        months += 12
      end

      output[:years]   = years
      output[:months]  = months
      output[:weeks]   = weeks
      output[:days]    = days

      total_days, @distance = distance.abs.divmod(ONE_DAY.to_i)

      [total_days, @distance]
    end
  end
end
