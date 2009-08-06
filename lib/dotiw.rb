module ActionView
  module Helpers
    module DateHelper
      def distance_of_time_in_words_hash(from_time, to_time)
        output = HashWithIndifferentAccess.new
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance = from_time - to_time
        
        # Get a positive number.
        distance *= -1 if distance < 0
        
        while distance > 0
          if distance > 100000000000000
            
          elsif distance >= 31449600
            output[I18n.t(:years, :default => "years")], distance = distance.divmod(31449600)
          elsif distance >= 2419200
            output[I18n.t(:months, :default => "months")], distance = distance.divmod(2419200)
          elsif distance >= 604800
            output[I18n.t(:weeks, :default => "weeks")], distance = distance.divmod(604800)
          elsif distance >= 86400
            output[I18n.t(:days, :default => "days")], distance = distance.divmod(86400)
          elsif distance >= 3600
            output[I18n.t(:hours, :default => "hours")], distance = distance.divmod(3600)
          elsif distance >= 60
            output[I18n.t(:minutes, :default => "minutes")], distance = distance.divmod(60)
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
          hash[key].nil?
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
       