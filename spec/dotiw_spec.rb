require File.join(File.dirname(__FILE__), 'spec_helper')
require 'dotiw'

describe "A better distance_of_time_in_words" do
  include ActionView::Helpers::DateHelper
  
  before do
    I18n.locale = :en
    time = "01-08-2009".to_time
    Time.stub!(:now).and_return(time)
    Time.zone.stub!(:now).and_return(time)
  end
  
  describe "hash version" do
    describe "giving correct numbers of" do
      
      [:years, :months, :weeks, :days, :minutes, :seconds].each do |name|
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
    
      it "debe hablar español" do
        I18n.locale = :es
        hash = distance_of_time_in_words_hash(Time.now, Time.now + 5.days)  
        hash["día"].should eql(5)
      end
    end
  end
  
  describe "real version" do
    [
      [Time.now, Time.now + 5.days + 3.minutes, "5 days and 3 minutes"],
      [Time.now, Time.now + 1.minute, "1 minute"],
      [Time.now, Time.now + 10.years, "10 years"]
    ].each do |start, finish, output|
      it "should be #{output}" do
        distance_of_time_in_words(start, finish).should eql(output)
      end
    end
  end
    
end