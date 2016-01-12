# dotiw [![](https://travis-ci.org/radar/dotiw.png)](https://travis-ci.org/radar/dotiw)

dotiw is a gem for Rails that overrides the default `distance_of_time_in_words` and provides a more accurate output. Do you crave accuracy down to the second? So do I. That's why I made this gem. Take this for a totally kickass example:

    >> distance_of_time_in_words(Time.now, Time.now + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds, true)
    => "1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds"

Also if one of the measurement is zero it will not output it:

    >> distance_of_time_in_words(Time.now, Time.now + 1.year + 2.months + 5.hours + 6.minutes + 7.seconds, true)
    => "1 year, 2 months, 4 days, 6 minutes, and 7 seconds"

Better than "about 1 year", am I right? Of course I am.

"But Ryan!", you say, "What happens if the time is only in seconds but because of the default the seconds aren't shown? Won't it be blank?"
"No!" I triumphantly reply:

    >> distance_of_time_in_words(Time.now, Time.now + 1.second, false)
    => "1 second"

The third argument for this method is whether or not to include seconds. By default this is `false` (because in Rails' `distance_of_time_in_words` it is), you can turn it on though by passing `true` as the third argument:

    >> distance_of_time_in_words(Time.now, Time.now + 1.year + 1.second, true)
    => "1 year, and 1 second"

Yes this could just be merged into the options hash but I'm leaving it here to ensure "backwards-compatibility",
because that's just an insanely radical thing to do. \m/

The last argument is an optional options hash that can be used to manipulate behavior and (which uses `to_sentence`).

Don't like having to pass in `Time.now` all the time? Then use `time_ago_in_words` which also will *rock your
world*:

    >> time_ago_in_words(Time.now + 3.days + 1.second)
    => "3 days, and 1 second"

Oh, and did I mention it supports I18n? Oh yeah. Rock on!

## Install

Install it as a gem:

```ruby
gem 'dotiw'
```

Or from GitHub:

```ruby
gem 'dotiw', github: 'radar/dotiw'
```

### Options

#### :locale

You can pass in a locale and it'll output it in whatever language you want (provided you have translations, otherwise it'll default to your app's default locale (the `config.i18n.default_locale` you have set in `/config/application.rb`):

    >> distance_of_time_in_words(Time.now, Time.now + 1.minute, false, :locale => :es)
    => "1 minuto"

This will also be passed to `to_sentence`

#### :vague

Specify this if you want it to use the old `distance_of_time_in_words`. The value can be anything except `nil` or `false`.

#### :accumulate_on

Specifies the maximum output unit which will accumulate all the surplus. Say you set it to seconds and your time difference is of 2 minutes then the output would be 120 seconds. Here's a code example:

    >> distance_of_time_in_words(Time.now, Time.now + 2.hours + 70.seconds, true, :accumulate_on => :minutes)
    => "121 minutes and 10 seconds"

#### :only

Only want a specific measurement of time? No problem!

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute, false, :only => :minutes)
    => "1 minute"

You only want some? No problem too!

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.day + 1.minute, false, :only => [:minutes, :hours])
    => "1 hour and 1 minute"

#### :except

Don't want a measurement of time? No problem!

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute, false, :except => :minutes)
    => "1 hour"

Culling a whole group of measurements of time:

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.day + 1.minute, false, :except => [:minutes, :hours])
    => "1 day"

#### :highest\_measure\_only

For times when Rails `distance_of_time_in_words` is not precise enough and `DOTIW` is too precise. For instance, if you only want to know the highest time part (measure) that elapsed between two dates.

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute + 1.second, true, :highest_measure_only => true)
    => "1 hour"

Notice how minutes and seconds were removed from the output. Another example:

    >> distance_of_time_in_words(Time.now, Time.now + 1.minute + 1.second, true, :highest_measure_only => true)
    => "1 minute"

Minutes are the highest measure, so seconds were discarded from the output.

#### :highest\_measures

When you want variable precision from `DOTIW`:

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute + 1.second, true, :highest_measures => 2)
    => "1 hour and 1 minute"

#### :words_connector

**This is an option for `to_sentence`, defaults to ', '**

Using something other than a comma:

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute + 1.second, true, :words_connector => ' - ')
    => "1 hour - 1 minute, and 1 second"

#### :two\_words\_connector

**This is an option for `to_sentence`, defaults to ' and '**

Using something other than 'and':

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute, true, :two_words_connector => ' plus ')
    => "1 hour plus 1 minute"

#### :last\_word\_connector

**This is an option for `to_sentence`, defaults to ', and '**

Using something other than ', and':

    >> distance_of_time_in_words(Time.now, Time.now + 1.hour + 1.minute + 1.second, true, :last_word_connector => ', finally ')
    => "1 hour, 1 minute, finally 1 second"

## distance\_of\_time

If you have simply a number of seconds you can get the "stringified" version of this by using `distance_of_time`:

    >> distance_of_time(300)
    => "5 minutes"

## distance\_of\_time\_in\_words\_hash

Don't like any format you're given? That's cool too! Here, have an indifferent hash version:

    >> distance_of_time_in_words_hash(Time.now, Time.now + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds)
    => {:days => 4, :weeks => 3, :seconds => 7, :minutes => 6, :years => 1, :hours => 5, :months => 2}

Indifferent means that you can access all keys by their `String` or `Symbol` version.

## distance\_of\_time\_in\_percent

If you want to calculate a distance of time in percent, use `distance_of_time_in_percent`. The first argument is the beginning time, the second argument the "current" time and the third argument is the end time. This method takes the same options as [`number_with_precision`](http://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_with_precision).

    distance_of_time_in_percent("04-12-2009".to_time, "29-01-2010".to_time, "04-12-2010".to_time, options)


## Contributors

* [chendo](http://github.com/chendo) - for talking through it with me and drawing on the whiteboard
* [Derander](http://github.com/derander) - correct Spanish translations
* [DBA](http://github.com/dba) - commits leading up to the 0.7 release
* [Sija](http://github.com/Sija) - rails 4 support, v2.0 release
