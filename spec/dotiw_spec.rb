# encoding: utf-8
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'dotiw'

describe "A better distance_of_time_in_words" do
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  
  before do
    I18n.locale = :en
    time = "01-08-2009".to_time
    Time.stub!(:now).and_return(time)
    Time.zone.stub!(:now).and_return(time)
  end
  
  describe "distance of time" do
    [
      [5.minutes.to_i, "5 minutes"],
      [10.minutes.to_i, "10 minutes"],
      [1.hour.to_i, "1 hour"],
      [4.weeks.to_i, "28 days"],
      [24.weeks.to_i, "5 months and 15 days"]
    ].each do |number, result|
      it "#{number} == #{result}" do
        distance_of_time(number).should eql(result)
      end
    end
  end
  
  describe "hash version" do
    describe "giving correct numbers of" do
      
      [:years, :months, :days, :minutes, :seconds].each do |name|
        describe name do
          it "exactly" do
            hash = distance_of_time_in_words_hash(Time.now, Time.now + 1.send(name))
            hash[name].should eql(1)    
          end

          it "two" do
            hash = distance_of_time_in_words_hash(Time.now, Time.now + 2.send(name))
            hash[name].should eql(2)
          end    
        end
      end
      
      it "should be happy with lots of measurements" do
        hash = distance_of_time_in_words_hash(Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds)
        hash[:years].should eql(1)
        hash[:months].should eql(2)
        hash[:days].should eql(3)
        hash[:hours].should eql(4)
        hash[:minutes].should eql(5)
        hash[:seconds].should eql(6)
      end
      
      it "debe estar contento con las mediciones en español" do
        hash = distance_of_time_in_words_hash(Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, :locale => "es")
        hash[:años].should eql(1)
        hash[:meses].should eql(2)
        hash[:días].should eql(3)
        hash[:horas].should eql(4)
        hash[:minutos].should eql(5)
        hash[:segundos].should eql(6)
      end
        
    
      it "debe hablar español" do
        I18n.locale = :es
        hash = distance_of_time_in_words_hash(Time.now, Time.now + 5.days)  
        hash["días"].should eql(5)
      end
    end
  end
  
  describe "real version" do
    it "debe hablar español" do
      distance_of_time_in_words(Time.now, Time.now + 5.days, true, :locale => "es").should eql("5 días")
    end
    
    [
      [Time.now, Time.now + 5.days + 3.minutes, "5 days and 3 minutes"],
      [Time.now, Time.now + 1.minute, "1 minute"],
      [Time.now, Time.now + 3.years, "3 years"],
      [Time.now, Time.now + 10.years, "10 years"],
      [Time.now, Time.now + 3.hour, "3 hours"],
      # Need to be +1.day because it will output "1 year and 30 days" otherwise.
      # Haven't investigated fully how this is caused.
      [Time.now, Time.now + 13.months + 1.day, "1 year and 1 month"],
      # Any numeric sequence is merely coincidental.
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      ["2009-3-16".to_time, "2008-4-14".to_time, "11 months and 2 days"],
      ["2009-3-16".to_time + 1.minute, "2008-4-14".to_time, "11 months, 2 days, and 1 minute"],
      ["2009-4-14".to_time, "2008-3-16".to_time, "1 year and 29 days"],
      ["2009-2-01".to_time, "2009-3-01".to_time, "1 month"],
      ["2008-2-01".to_time, "2008-3-01".to_time, "1 month"]
    ].each do |start, finish, output|
      it "should be #{output}" do
        distance_of_time_in_words(start, finish, true).should eql(output)
      end
    end
  end
  
  describe "with output options" do
   [
      # Any numeric sequence is merely coincidental.
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :words_connector => " - " }, "1 year - 2 months - 3 days - 4 hours - 5 minutes, and 6 seconds"],
      
      [Time.now, Time.now + 5.minutes + 6.seconds, { :two_words_connector => " - " }, "5 minutes - 6 seconds"],
      
      [Time.now, Time.now + 4.hours +  5.minutes + 6.seconds, { :last_word_connector => " - " }, "4 hours, 5 minutes - 6 seconds"],
      
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :except => "minutes" }, "1 year, 2 months, 3 days, 4 hours, and 6 seconds"],
      [Time.now, Time.now + 1.hour + 1.minute, { :except => "minutes"}, "1 hour"],
      [Time.now, Time.now + 1.hour + 1.day + 1.minute, { :except => ["minutes", "hours"]}, "1 day"],
      
      [Time.now, Time.now + 1.hour + 1.day + 1.minute, { :only => ["minutes", "hours"]}, "1 hour and 1 minute"],
      
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :precision => 2 }, "1 year and 2 months"],
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :precision => 3 }, "1 year, 2 months, and 3 days"],
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :precision => 10 }, "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :vague => true }, "about 1 year"],
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :vague => "Yes please" }, "about 1 year"],
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :vague => false }, "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { :vague => nil }, "1 year, 2 months, 3 days, 4 hours, 5 minutes, and 6 seconds"],
      [Time.now, Time.now + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds, { "except" => "minutes" }, "1 year, 2 months, 3 days, 4 hours, and 6 seconds"],
    ].each do |start, finish, options, output|
      it "should be #{output}" do
        distance_of_time_in_words(start, finish, true, options).should eql(output)
      end
    end
    
    it "outputs seconds regardless of include_seconds setting if only seconds have passed" do
      distance_of_time_in_words(Time.now, Time.now + 1.second).should eql("1 second")
    end
    
  end
  
  describe "percentage of time" do
    
    def time_in_percent(options = {})
      distance_of_time_in_percent("04-12-2009".to_time, "29-01-2010".to_time, "04-12-2010".to_time, options)
    end
    
    it "calculates 15%" do
      time_in_percent.should eql("15%")
    end
    
    it "calculates 15.3%" do
      time_in_percent(:precision => 1).should eql("15.3%")
    end
    
  end
    
end