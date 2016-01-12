# encoding: utf-8

require 'spec_helper'

describe "A better distance_of_time_in_words" do
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  START_TIME = "01-08-2009".to_time

  before do
    I18n.locale = :en
    allow(Time).to receive(:now).and_return(START_TIME)
    allow(Time.zone).to receive(:now).and_return(START_TIME)
  end

  describe "distance of time" do
    fragments = [
      [0.5.minutes, "30 seconds"],
      [4.5.minutes, "4 minutes and 30 seconds"],
      [5.minutes.to_i, "5 minutes"],
      [10.minutes.to_i, "10 minutes"],
      [1.hour.to_i, "1 hour"],
      [1.hour + 30.seconds, "1 hour and 30 seconds"],
      [4.weeks.to_i, "4 weeks"],
      [4.weeks + 2.days, "4 weeks and 2 days"],
      [24.weeks.to_i, "5 months, 2 weeks, and 1 day"]
    ]
    fragments.each do |number, result|
      it "#{number} == #{result}" do
        expect(distance_of_time(number)).to eq(result)
      end
    end

    describe "with options" do
      it "except:seconds should skip seconds" do
        expect(distance_of_time(1.2.minute, except: 'seconds')).to eq("1 minute")
        expect(distance_of_time(2.5.hours + 30.seconds, except: 'seconds')).to eq("2 hours and 30 minutes")
      end

      it "except:seconds has higher precedence than include_seconds:true" do
        expect(distance_of_time(1.2.minute, include_seconds: true, except: 'seconds')).to eq('1 minute')
      end
    end

  end

  describe "hash version" do
    describe "giving correct numbers of" do

      [:years, :months, :weeks, :days, :minutes, :seconds].each do |name|
        describe name do
          it "exactly" do
            hash = distance_of_time_in_words_hash(START_TIME, START_TIME + 1.send(name))
            expect(hash[name]).to eq(1)
          end

          it "two" do
            hash = distance_of_time_in_words_hash(START_TIME, START_TIME + 2.send(name))
            expect(hash[name]).to eq(2)
          end
        end
      end

      it "should be happy with lots of measurements" do
        hash = distance_of_time_in_words_hash(START_TIME,
                                              START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds)
        expect(hash[:years]).to eq(1)
        expect(hash[:months]).to eq(2)
        expect(hash[:weeks]).to eq(3)
        expect(hash[:days]).to eq(4)
        expect(hash[:hours]).to eq(5)
        expect(hash[:minutes]).to eq(6)
        expect(hash[:seconds]).to eq(7)
      end
    end
  end

  describe "real version" do
    it "debe hablar español" do
      expect(distance_of_time_in_words(START_TIME, START_TIME + 1.days, :locale => :es)).to eq("un día")
      expect(distance_of_time_in_words(START_TIME, START_TIME + 5.days, :locale => :es)).to eq("5 días")
    end

    it "deve parlare l'italiano" do
      expect(distance_of_time_in_words(START_TIME, START_TIME + 1.days, true, :locale => :it)).to eq("un giorno")
      expect(distance_of_time_in_words(START_TIME, START_TIME + 5.days, true, :locale => :it)).to eq("5 giorni")
    end

    fragments = [
      [START_TIME, START_TIME + 5.days + 3.minutes, "5 days and 3 minutes"],
      [START_TIME, START_TIME + 1.minute, "1 minute"],
      [START_TIME, START_TIME + 3.years, "3 years"],
      [START_TIME, START_TIME + 10.years, "10 years"],
      [START_TIME, START_TIME + 8.months, "8 months"],
      [START_TIME, START_TIME + 3.hour, "3 hours"],
      [START_TIME, START_TIME + 13.months, "1 year and 1 month"],
      # Any numeric sequence is merely coincidental.
      [START_TIME, START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds, "1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds"],
      ["2009-3-16".to_time, "2008-4-14".to_time, "11 months and 2 days"],
      ["2009-3-16".to_time + 1.minute, "2008-4-14".to_time, "11 months, 2 days, and 1 minute"],
      ["2009-4-14".to_time, "2008-3-16".to_time, "1 year, 4 weeks, and 1 day"],
      ["2009-2-01".to_time, "2009-3-01".to_time, "1 month"],
      ["2008-2-01".to_time, "2008-3-01".to_time, "1 month"]
    ]
    fragments.each do |start, finish, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, true)).to eq(output)
      end
    end

    describe "accumulate on" do
      fragments = [
        [START_TIME,
         START_TIME + 10.minute,
         :seconds,
         "600 seconds"],
        [START_TIME,
         START_TIME + 10.hour + 10.minute + 1.second,
         :minutes,
         "610 minutes and 1 second"],
        [START_TIME,
         START_TIME + 2.day + 10000.hour + 10.second,
         :hours,
         "10048 hours and 10 seconds"],
        [START_TIME,
         START_TIME + 2.day + 10000.hour + 10.second,
         :days,
         "418 days, 16 hours, and 10 seconds"],
        [START_TIME,
         START_TIME + 2.day + 10000.hour + 10.second,
         :weeks,
         "59 weeks, 5 days, 16 hours, and 10 seconds"],
        [START_TIME,
         START_TIME + 2.day + 10000.hour + 10.second,
         :months,
         "13 months, 3 weeks, 1 day, 16 hours, and 10 seconds"],
        ["2015-1-15".to_time, "2016-3-15".to_time, :months, "14 months"]

      ]
      fragments.each do |start, finish, accumulator, output|
        it "should be #{output}" do
          expect(distance_of_time_in_words(start, finish, true, :accumulate_on => accumulator)).to eq(output)
        end
      end
    end # :accumulate_on

    describe "without finish time" do
      # A missing finish argument should default to zero, essentially returning
      # the equivalent of distance_of_time in order to be backwards-compatible
      # with the original rails distance_of_time_in_words helper.
      fragments = [
        [5.minutes.to_i, "5 minutes"],
        [10.minutes.to_i, "10 minutes"],
        [1.hour.to_i, "1 hour"],
        [6.days.to_i, "6 days"],
        [4.weeks.to_i, "4 weeks"],
        [24.weeks.to_i, "5 months, 2 weeks, and 1 day"]
      ]
      fragments.each do |start, output|
        it "should be #{output}" do
          expect(distance_of_time_in_words(start)).to eq(output)
        end
      end
    end

  end

  describe "with output options" do
    fragments = [
      # Any numeric sequence is merely coincidental.
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :words_connector => " - " },
       "1 year - 2 months - 3 weeks - 4 days - 5 hours - 6 minutes, and 7 seconds"],
      [START_TIME,
       START_TIME + 5.minutes + 6.seconds,
       { :two_words_connector => " - " },
       "5 minutes - 6 seconds"],
      [START_TIME,
       START_TIME + 4.hours +  5.minutes + 6.seconds,
       { :last_word_connector => " - " },
       "4 hours, 5 minutes - 6 seconds"],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :except => "minutes" },
       "1 year, 2 months, 3 days, 4 hours, and 6 seconds"],
      [START_TIME,
       START_TIME + 1.hour + 1.minute,
       { :except => "minutes"}, "1 hour"],
      [START_TIME,
       START_TIME + 1.hour + 1.day + 1.minute,
       { :except => ["minutes", "hours"]},
       "1 day"],
      [START_TIME,
       START_TIME + 1.hour + 1.day + 1.minute,
       { :only => ["minutes", "hours"]},
       "1 hour and 1 minute"],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :vague => true },
       "about 1 year"],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :vague => "Yes please" },
       "about 1 year"],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :vague => false },
       "1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds"],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :vague => nil },
       "1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds"],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :except => "minutes" },
       "1 year, 2 months, 3 weeks, 4 days, 5 hours, and 7 seconds"],
      [START_TIME,
        START_TIME + 1.hour + 2.minutes + 3.seconds,
        { :highest_measure_only => true },
        "1 hour"],
      [START_TIME,
       START_TIME + 1.hours + 2.minutes + 3.seconds,
       { :highest_measures => 1 },
       "1 hour"],
      [START_TIME,
       START_TIME + 2.year + 3.months + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :highest_measures => 3 },
       "2 years, 3 months, and 4 days"],
      [START_TIME,
       START_TIME + 2.year + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :highest_measures => 2 },
       "2 years and 3 weeks"],
      [START_TIME,
       START_TIME + 4.days + 6.minutes + 7.seconds,
       { :highest_measures => 3 },
       "4 days, 6 minutes, and 7 seconds"],
      [START_TIME,
       START_TIME + 1.year + 2.weeks,
       { :highest_measures => 3 },
       "1 year and 2 weeks"],
      [START_TIME,
       START_TIME + 1.days,
       { :only => [:years, :months] },
       "less than 1 month"],
      [START_TIME,
       START_TIME + 5.minutes,
       { :except => [:hours, :minutes, :seconds] },
       "less than 1 day"],
      [START_TIME,
       START_TIME + 1.days,
       { :highest_measures => 1, :only => [:years, :months] },
       "less than 1 month"]
    ]
    fragments.each do |start, finish, options, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, true, options)).to eq(output)
      end
    end

    describe "include_seconds" do
      it "is ignored if only seconds have passed" do
        expect(distance_of_time_in_words(START_TIME, START_TIME + 1.second, false)).to eq("1 second")
      end

      it "removes seconds in all other cases" do
        expect(distance_of_time_in_words(START_TIME,
                                  START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
                                  false)).to eq("1 year, 2 months, 3 weeks, 4 days, 5 hours, and 6 minutes")
      end
    end # include_seconds
  end

  describe "percentage of time" do
    def time_in_percent(options = {})
      distance_of_time_in_percent("04-12-2009".to_time, "29-01-2010".to_time, "04-12-2010".to_time, options)
    end

    it "calculates 15%" do
      expect(time_in_percent).to eq("15%")
    end

    it "calculates 15.3%" do
      expect(time_in_percent(:precision => 1)).to eq("15.3%")
    end
  end

end
