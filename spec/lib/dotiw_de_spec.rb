require 'spec_helper'


def dotiw_call(time, locale)
  return distance_of_time_in_words(Time.now, Time.now + time, false, :locale => locale)
end

describe "dotiw" do

  describe "dotiw is able to display several time objects in singularized locale 'DE'" do

    describe "1.hour" do

      before :all do
        @time = 1.hour
      end

      it "EN" do
        output = dotiw_call(@time, "en")
        output.should eql "1 hour"
      end

      it "DE" do
        output = dotiw_call(@time, "de")
        output.should eql "1 Stunde"
      end

    end

    describe "2.hours" do

      before :all do
        @time = 2.hours
      end

      it "EN" do
        output = dotiw_call(@time, "en")
        output.should eql "2 hours"
      end

      it "DE" do
        output = dotiw_call(@time, "de")
        output.should eql "2 Stunden"
      end

    end

    describe "1.minute" do

      before :all do
        @time = 1.minute
      end

      it "EN" do
        output = dotiw_call(@time, "en")
        output.should eql "1 minute"
      end

      it "DE" do
        output = dotiw_call(@time, "de")
        output.should eql "1 Minute"
      end

    end

    describe "2.minutes" do

      before :all do
        @time = 2.minutes
      end

      it "EN" do
        output = dotiw_call(@time, "en")
        output.should eql "2 minutes"
      end

      it "DE" do
        output = dotiw_call(@time, "de")
        output.should eql "2 Minuten"
      end

    end

  end

end
