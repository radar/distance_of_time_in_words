# dotiw

dotiw is a plugin for Rails that overrides the default `distance_of_time_in_words` and provides a more accurate output. Do you crave accuracy down to the second? So do I. That's why I made this plugin. Take this for a totally kickass example:

    >> distance_of_time_in_words(Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, true)
    => "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"
     
Also if one of the measurement is zero it will not output it:

    >> distance_of_time_in_words(Time.now, Time.now + 1.year + 2.months + 4.hours + 5.minutes + 6.seconds, true)
    => "1 year, 2 months, 4 hours, 5 minutes, and 6 seconds"
     
Better than "about 1 year", am I right? Of course I am.

This takes the same options plus an additional one on the end for passing options to the output (which uses `to_sentence`). 

Oh, and did I mention it supports I18n? Oh yeah.

## distance\_of\_time\_in\_words\_hash

Don't like any format you're given? That's cool too! Here, have an indifferent hash version:

    >> distance_of_time_in_words_hash(Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds)
    => {"days"=>3, "seconds"=>6, "minutes"=>5, "years"=>1, "hours"=>4, "months"=>2}

Indiferrent means that you can access all keys by their `String` or `Symbol` version.

### Options

#### :locale

The keys can be in your local language too:

    >> distance_of_time_in_words_hash(Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, :locale => "es")
    => {"horas"=>4, "días"=>3, "minutos"=>5, "segundos"=>6, "años"=>1, "meses"=>2}
    
You are not guaranteed the order of the hash in Ruby 1.8.

## distance\_of\_time\_in\_words

### Options

The third argument for this method is whether or not to include seconds. By default this is `false` (because in Rails' `distance_of_time_in_words` it is), you can turn it on though by passing `true` as the third argument:

    >> distance_of_time_in_words(Time.now, Time.now + 1.year + 1.second, true)
    => "1 year, and 1 second" 
    
Yes this could just be merged into the options hash but I'm leaving it here to ensure "backwards-compatibility".

#### :locale

You can pass in a locale and it'll output it in whatever language you want (provided you have translations, otherwise it'll default to English):

    >> distance_of_time_in_words(Time.now, Time.now + 1.minute, false, :locale => "es")
    => "1 minuto"
    
This will also be passed to `to_sentence`

#### :except

**Note that values passed into this option must be passed in as strings!**

Don't want a measurement of time? No problem!

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute, false, :except => "minutes")
    => "1 hour"

Culling a whole group of measurements of time:

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.day + 1.minute, false, :except => ["minutes", "hours"])
    => "1 day"
    
#### :words_connector

**This is an option for `to_sentence`, defaults to ', '**

Using something other than a comma:

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute + 1.second, true, { :words_connector => ' - ' })
    => "1 hour - 1 minute, and 1 second"
    
#### :two\_words\_connector

**This is an option for `to_sentence`, defaults to ' and '**

Using something other than 'and':

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute, true, { :two_words_connector => ' plus ' })
    => "1 hour plus 1 minute"

#### :last\_word\_connector 

**This is an option for `to_sentence`, defaults to ', and '**

Using something other than ', and':

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute + 1.second, true, { :last_word_connector => ', finally ' })
    => "1 hour, 1 minute, finally 1 second"
    
## Contributors

chendo - for talking through it with me and drawing on the whiteboard
Derander - correct Spanish translations