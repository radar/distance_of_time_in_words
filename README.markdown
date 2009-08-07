# dotiw

dotiw is a plugin for Rails that overrides the default `distance_of_time_in_words` and provides a more accurate output. Do you crave accuracy down to the second? So do I. That's why I made this plugin. Take this for a totally kickass example:

     >> distance_of_time_in_words(Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds)
     => "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"
     
Better than "about 1 year", am I right? Of course I am.

This takes the same options plus an additional one on the end for passing options to the output (which uses `to_sentence`). 

## Contributors

chendo - for talking through it with me and drawing on the whiteboard
Derander - correct Spanish translations