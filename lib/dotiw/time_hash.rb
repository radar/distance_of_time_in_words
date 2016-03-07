# encoding: utf-8

module DOTIW
  class TimeHash
    TIME_FRACTIONS = [:seconds, :minutes, :hours, :days, :weeks, :months, :years]

    attr_accessor :distance, :smallest, :largest, :from_time, :to_time

    def initialize(distance, from_time = nil, to_time = nil, options = {})
      self.output     = ActiveSupport::OrderedHash.new
      self.options    = options
      self.distance   = distance
      self.from_time  = from_time || Time.current
      self.to_time    = to_time   || (@to_time_not_given = true && self.from_time + self.distance.seconds)
      self.smallest, self.largest = [self.from_time, self.to_time].minmax
      self.to_time   += 1.hour if @to_time_not_given && self.smallest.dst? && !self.largest.dst?
      self.to_time   -= 1.hour if @to_time_not_given && !self.smallest.dst? && self.largest.dst?
      self.smallest, self.largest = [self.from_time, self.to_time].minmax
      self.distance ||= begin
        d = largest - smallest
        d -= 1.hour if self.smallest.dst? && !self.largest.dst?
        d += 1.hour if !self.smallest.dst? && self.largest.dst?
        d
      end

      build_time_hash
    end

    def to_hash
      output
    end

  private
    attr_accessor :options, :output

    def build_time_hash
      if accumulate_on = options.delete(:accumulate_on)
        accumulate_on = accumulate_on.to_sym
        if accumulate_on == :years
          return build_time_hash
        end
        TIME_FRACTIONS.index(accumulate_on).downto(0) { |i| self.send("build_#{TIME_FRACTIONS[i]}") }
      else
        while distance > 0
          if distance < 1.minute
            build_seconds
          elsif distance < 1.hour
            build_minutes
          elsif distance < 1.day
            build_hours
          elsif distance < 7.days
            build_days
          elsif distance < 28.days
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
      self.distance = 0
    end

    def build_minutes
      output[:minutes], self.distance = distance.divmod(1.minute)
    end

    def build_hours
      output[:hours], self.distance = distance.divmod(1.hour)
    end

    def build_days
      output[:days], self.distance = distance.divmod(1.day) if output[:days].nil?
    end

    def build_weeks
      output[:weeks], self.distance = distance.divmod(1.week) if output[:weeks].nil?
    end

    def build_months
      build_years_months_weeks_days

      if (years = output.delete(:years)) > 0
        output[:months] += (years * 12)
      end
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
        last_month = largest.advance(:months => -1)
        days_in_month = Time.days_in_month(last_month.month, last_month.year)
        weeks += days_in_month / 7
        days += days_in_month % 7
        if days >= 7
          days -= 7
          weeks += 1
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

      total_days, self.distance = distance.abs.divmod(1.day)

      [total_days, self.distance]
    end
  end # TimeHash
end # DOTIW
