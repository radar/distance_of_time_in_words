module ActionView
  module Helpers
    module DateHelper
      def distance_of_time_in_words_hash(from_time, to_time, options={})
        output = HashWithIndifferentAccess.new
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        
        distance = (from_time - to_time).abs
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
      
      def distance_of_time_in_words(from_time, to_time, include_seconds = false, options = {})
        hash = distance_of_time_in_words_hash(from_time, to_time, options)
        hash.delete(:seconds) if !include_seconds
        I18n.with_options :locale => options[:locale] do |locale|
          # Remove all the values that are nil.
          time_measurements = [locale.t(:years, :default => "years"),
                               locale.t(:months, :default => "months"),
                               locale.t(:weeks, :default => "weeks"),
                               locale.t(:days, :default => "days"),
                               locale.t(:hours, :default => "hours"),
                               locale.t(:minutes, :default => "minutes"),
                               locale.t(:seconds, :default => "seconds")].delete_if do |key|
            hash[key].nil? || hash[key].zero? || (!options[:except].nil? && options[:except].include?(key))
          end
       
          options.delete(:except)
        
          output = []
          time_measurements.each do |key|
            name = hash[key] > 1 ? key : key.singularize
            output += ["#{hash[key]} #{name}"]
          end
        
          output.to_sentence(options)
        end    
      end
    end
  end
end
       