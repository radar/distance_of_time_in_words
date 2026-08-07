# frozen_string_literal: true

require 'spec_helper'

describe DOTIW do
  START_TIME_MODULE = '01-08-2009'.to_time(:utc)

  before do
    I18n.locale = :en
  end

  describe '.distance_of_time_in_words' do
    it 'returns the exact distance' do
      expect(
        described_class.distance_of_time_in_words(START_TIME_MODULE, START_TIME_MODULE + 1.hour + 30.minutes)
      ).to eq('1 hour and 30 minutes')
    end

    it 'accepts options' do
      expect(
        described_class.distance_of_time_in_words(
          START_TIME_MODULE, START_TIME_MODULE + 1.hour + 30.minutes, highest_measures: 1
        )
      ).to eq('1 hour')
    end
  end

  describe '.time_ago_in_words' do
    it 'returns the distance to now' do
      allow(Time).to receive(:now).and_return(START_TIME_MODULE)
      allow(Time.zone).to receive(:now).and_return(START_TIME_MODULE)

      expect(
        described_class.time_ago_in_words(START_TIME_MODULE - 90, include_seconds: true)
      ).to eq('1 minute and 30 seconds')
    end
  end

  describe '.distance_of_time' do
    it 'returns the distance for a number of seconds' do
      expect(described_class.distance_of_time(90)).to eq('1 minute and 30 seconds')
    end
  end

  describe '.distance_of_time_in_words_hash' do
    it 'returns the distance as a hash' do
      expect(
        described_class.distance_of_time_in_words_hash(START_TIME_MODULE, START_TIME_MODULE + 1.hour + 30.minutes)
      ).to include(hours: 1, minutes: 30)
    end
  end
end
