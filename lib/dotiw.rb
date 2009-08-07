module ActionView
  module Helpers
    module DateHelper
      def distance_of_time_in_words_hash(from_time, to_time)
        output = HashWithIndifferentAccess.new
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance = (from_time - to_time).abs
        
        while distance > 0
          if distance > 100000000000000
            
          elsif distance >= 1.month 
            smallest, largest = from_time < to_time ? [from_time, to_time] : [to_time, from_time]   
            
            months = (largest.year - smallest.year) * 12 + (largest.month - smallest.month)
            years, months = months.divmod(12)
            
            days = largest.day - smallest.day
            
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
            
            output[I18n.t(:years, :default => "years")] = years
            output[I18n.t(:months, :default => "months")] = months
            output[I18n.t(:days, :default => "days")] = days
            
            total_days, distance = distance.divmod(1.day)
          # elsif distance >= 1.week
          #   output[I18n.t(:weeks, :default => "weeks")], distance = distance.divmod(1.week)
          elsif distance >= 1.day
            output[I18n.t(:days, :default => "days")], distance = distance.divmod(1.day)
          elsif distance >= 1.hour
            output[I18n.t(:hours, :default => "hours")], distance = distance.divmod(1.hour)
          elsif distance >= 1.minute
            output[I18n.t(:minutes, :default => "minutes")], distance = distance.divmod(1.minute)
          else
            output[I18n.t(:seconds, :default => "seconds")] = distance.to_i
            distance = 0
          end
        end
        output
      end
      
      def distance_of_time_in_words(from_time, to_time, include_seconds = false, options = {}, output_options = {})
        hash = distance_of_time_in_words_hash(from_time, to_time)
        hash.delete(:seconds) if !include_seconds
        
        # Remove all the values that are nil.
        time_measurements = [I18n.t(:years, :default => "years"),
                             I18n.t(:months, :default => "months"),
                             I18n.t(:weeks, :default => "weeks"),
                             I18n.t(:days, :default => "days"),
                             I18n.t(:hours, :default => "hours"),
                             I18n.t(:minutes, :default => "minutes"),
                             I18n.t(:seconds, :default => "seconds")].delete_if do |key|
          hash[key].nil? || hash[key].zero?
        end
        
        output = []
        time_measurements.each do |key|
          name = hash[key] > 1 ? key : key.singularize
          output += ["#{hash[key]} #{name}"]
        end
        
        output.to_sentence(output_options)
           
         
        
      end
    end
  end
end
       