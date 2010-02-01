# encoding: utf-8
module ActionView
  module Helpers
    module DateHelper
      def distance_of_time_in_words_hash(from_time, to_time, options={})
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        
        distance = (from_time - to_time).abs
        distance_of_time_hash(distance, from_time, to_time, options)
      end
      
      def distance_of_time_hash(distance, from_time = nil, to_time = nil, options={})
        output = HashWithIndifferentAccess.new
        from_time ||= Time.now
        to_time ||= from_time + distance.seconds
        I18n.with_options :locale => options[:locale] do |locale|
          while distance > 0
            if distance < 1.minute
              output[locale.t(:seconds, :default => "seconds")] = distance.to_i
              distance = 0
            elsif distance < 1.hour
              output[locale.t(:minutes, :default => "minutes")], distance = distance.divmod(1.minute)
            elsif distance < 1.day
              output[locale.t(:hours, :default => "hours")], distance = distance.divmod(1.hour)
            elsif distance < 28.days
              output[locale.t(:days, :default => "days")], distance = distance.divmod(1.day)
              # Time has to be greater than a month
            else
              smallest, largest = from_time < to_time ? [from_time, to_time] : [to_time, from_time]   
            
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
            
              output[locale.t(:years, :default => "years")] = years
              output[locale.t(:months, :default => "months")] = months
              output[locale.t(:days, :default => "days")] = days
            
              total_days, distance = distance.divmod(1.day)
            end
          end
        end
        output
      end
      
      alias_method :old_distance_of_time_in_words, :distance_of_time_in_words
      
      def distance_of_time(seconds, options = {})
        display_time_in_words(distance_of_time_hash(seconds), options)
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
        number_with_precision(((current_time - from_time) / distance) * 100, options).to_s + "%"
      end
    end
  end
end
       