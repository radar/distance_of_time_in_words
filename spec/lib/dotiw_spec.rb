# encoding: utf-8

require 'spec_helper'

describe "A better distance_of_time_in_words" do
  before do
    I18n.locale = :en
    time = "01-08-2009".to_time
    allow(Time).to receive(:now).and_return(time)
    allow(Time.zone).to receive(:now).and_return(time)
  end

  describe "distance of time" do
    [
      [0.5.minutes, "30 seconds"],
      [4.5.minutes, "4 minutes and 30 seconds"],
      [5.minutes.to_i, "5 minutes"],
      [10.minutes.to_i, "10 minutes"],
      [1.hour.to_i, "1 hour"],
      [1.hour + 30.seconds, "1 hour and 30 seconds"],
      [4.weeks.to_i, "28 days"],
      [24.weeks.to_i, "5 months and 15 days"]
    ].each do |number, result|
      it "#{number} == #{result}" do
        expect(distance_of_time(number)).to eq(result)
      end
    end

    describe "with options" do
      it "except:seconds should skip seconds" do
        expect(distance_of_time(1.2.minute, except: 'seconds')).to eq("1 minute")
        expect(distance_of_time(2.5.hours + 30.seconds, except: 'seconds')).to eq("2 hours and 30 minutes")
      end

      it "except:seconds har higher presedence than include_seconds:true" do
        expect(distance_of_time(1.2.minute, include_seconds: true, except: 'seconds')).to eq('1 minute')
      end
    end

  end

  describe "hash version" do
    describe "giving correct numbers of" do

      [:years, :months, :days, :minutes, :seconds].each do |name|
        describe name do
          it "exactly" do
            hash = distance_of_time_in_words_hash(Time.now, Time.now + 1.send(name))
            expect(hash[name.to_s]).to eq(1)
          end

          it "two" do
            hash = distance_of_time_in_words_hash(Time.now, Time.now + 2.send(name))
            expect(hash[name.to_s]).to eq(2)
          end
        end
      end

      it "should be happy with lots of measurements" do
        hash = distance_of_time_in_words_hash(Time.now,
                                              Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds)
        expect(hash["years"]).to eq(1)
        expect(hash["months"]).to eq(2)
        expect(hash["days"]).to eq(3)
        expect(hash["hours"]).to eq(4)
        expect(hash["minutes"]).to eq(5)
        expect(hash["seconds"]).to eq(6)
      end

      it "debe estar contento con las mediciones en español" do
        hash = distance_of_time_in_words_hash(Time.now,
                                              Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
                                              :locale => "es")
        expect(hash["años"]).to eq(1)
        expect(hash["meses"]).to eq(2)
        expect(hash["días"]).to eq(3)
        expect(hash["horas"]).to eq(4)
        expect(hash["minutos"]).to eq(5)
        expect(hash["segundos"]).to eq(6)
      end

      it "debe hablar español" do
        I18n.locale = :es
        hash = distance_of_time_in_words_hash(Time.now, Time.now + 5.days)
        expect(hash["días"]).to eq(5)
      end
    end
  end

  describe "real version" do
    it "debe hablar español" do
      expect(distance_of_time_in_words(Time.now, Time.now + 5.days, true, :locale => "es")).to eq("5 días")
    end

    [
      [Time.now, Time.now + 5.days + 3.minutes, "5 days and 3 minutes"],
      [Time.now, Time.now + 1.minute, "1 minute"],
      [Time.now, Time.now + 3.years, "3 years"],
      [Time.now, Time.now + 10.years, "10 years"],
      # previous fails, but the next one works
      [Time.zone.now, Time.zone.now + 10.years, "10 years"],
      [Time.now, Time.now + 3.hour, "3 hours"],
      # Need to be +1.day because it will output "1 year and 30 days" otherwise.
      # Haven't investigated fully how this is caused.
      [Time.now, Time.now + 13.months, "1 year and 1 month"],
      # Any numeric sequence is merely coincidental.
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      ["2009-3-16".to_time, "2008-4-14".to_time, "11 months and 2 days"],
      ["2009-3-16".to_time + 1.minute, "2008-4-14".to_time, "11 months, 2 days, and 1 minute"],
      ["2009-4-14".to_time, "2008-3-16".to_time, "1 year and 29 days"],
      ["2009-2-01".to_time, "2009-3-01".to_time, "1 month"],
      ["2008-2-01".to_time, "2008-3-01".to_time, "1 month"]
    ].each do |start, finish, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, true)).to eq(output)
      end
    end

    describe "accumulate on" do
      [
        [Time.now,
         Time.now + 10.minute,
         :seconds,
         "600 seconds"],
        [Time.now,
         Time.now + 10.hour + 10.minute + 1.second,
         :minutes,
         "610 minutes and 1 second"],
        [Time.now,
         Time.now + 2.day + 10000.hour + 10.second,
         :hours,
         "10048 hours and 10 seconds"],
        [Time.now,
         Time.now + 2.day + 10000.hour + 10.second,
         :days,
         "418 days, 16 hours, and 10 seconds"],
        [Time.now,
         Time.now + 2.day + 10000.hour + 10.second,
         :months,
         "13 months, 16 hours, and 10 seconds"],
        [Time.now,
         Time.now + 2.day + 10000.hour + 10.second,
         :years,
         "1 year, 1 month, 22 days, 16 hours, and 10 seconds"]
      ].each do |start, finish, accumulator, output|
        it "should be #{output}" do
          expect(distance_of_time_in_words(start, finish, true, :accumulate_on => accumulator)).to eql(output)
        end
      end
    end # :accumulate_on
  end

  describe "with output options" do
    [
      # Any numeric sequence is merely coincidental.
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :words_connector => " - " },
       "1 year - 2 months - 3 days - 4 hours - 5 minutes, and 6 seconds"],
      [Time.now,
       Time.now + 5.minutes + 6.seconds,
       { :two_words_connector => " - " },
       "5 minutes - 6 seconds"],
      [Time.now,
       Time.now + 4.hours +  5.minutes + 6.seconds,
       { :last_word_connector => " - " },
       "4 hours, 5 minutes - 6 seconds"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :except => "minutes" },
       "1 year, 2 months, 3 days, 4 hours, and 6 seconds"],
      [Time.now,
       Time.now + 1.hour + 1.minute,
       { :except => "minutes"}, "1 hour"],
      [Time.now,
       Time.now + 1.hour + 1.day + 1.minute,
       { :except => ["minutes", "hours"]},
       "1 day"],
      [Time.now,
       Time.now + 1.hour + 1.day + 1.minute,
       { :only => ["minutes", "hours"]},
       "1 hour and 1 minute"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :precision => 2 },
       "1 year and 2 months"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :precision => 3 },
       "1 year, 2 months, and 3 days"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :precision => 10 },
       "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :vague => true },
       "about 1 year"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :vague => "Yes please" },
       "about 1 year"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :vague => false },
       "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { :vague => nil },
       "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      [Time.now,
       Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { "except" => "minutes" },
       "1 year, 2 months, 3 days, 4 hours, and 6 seconds"],
      [Time.now,
        Time.now + 1.hour + 2.minutes + 3.seconds,
        { :highest_measure_only => true },
        "1 hour"],
      [Time.now,
       Time.now + 2.year + 3.months + 4.days + 5.hours + 6.minutes + 7.seconds,
       { :singularize => :always },
       "2 year, 3 month, 4 day, 5 hour, 6 minute, and 7 second"]
    ].each do |start, finish, options, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, true, options)).to eql(output)
      end
    end

    describe "include_seconds" do
      it "is ignored if only seconds have passed" do
        expect(distance_of_time_in_words(Time.now, Time.now + 1.second, false)).to eql("1 second")
      end

      it "removes seconds in all other cases" do
        expect(distance_of_time_in_words(Time.now,
                                         Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
                                         false)).to eql("1 year, 2 months, 3 days, 4 hours, and 5 minutes")
      end
    end # include_seconds
  end

  describe "percentage of time" do
    def time_in_percent(options = {})
      distance_of_time_in_percent("04-12-2009".to_time, "29-01-2010".to_time, "04-12-2010".to_time, options)
    end

    it "calculates 15%" do
      expect(time_in_percent).to eql("15%")
    end

    it "calculates 15.3%" do
      expect(time_in_percent(:precision => 1)).to eql("15.3%")
    end
  end

end
