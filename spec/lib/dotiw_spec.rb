# frozen_string_literal: true

require 'spec_helper'

describe 'A better distance_of_time_in_words' do
  if defined?(ActionView)
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper

    require 'action_controller'
  else
    include DOTIW::Methods
  end

  START_TIME = '01-08-2009'.to_time

  before do
    I18n.locale = :en
    allow(Time).to receive(:now).and_return(START_TIME)
    allow(Time.zone).to receive(:now).and_return(START_TIME)
  end

  describe '#distance_of_time' do
    [
      [0.5.minutes, '30 seconds'],
      [4.5.minutes, '4 minutes and 30 seconds'],
      [5.minutes, '5 minutes'],
      [10.minutes, '10 minutes'],
      [1.hour, '1 hour'],
      [1.hour + 30.seconds, '1 hour and 30 seconds'],
      [4.weeks, '4 weeks'],
      [4.weeks + 2.days, '4 weeks and 2 days'],
      [24.weeks, '5 months, 2 weeks, and 1 day']
    ].each do |number, result|
      it "#{number} == #{result}" do
        expect(distance_of_time(number)).to eq(result)
      end
    end

    describe 'with options' do
      it 'except:seconds should skip seconds' do
        expect(distance_of_time(1.2.minute, except: 'seconds')).to eq('1 minute')
        expect(distance_of_time(2.5.hours + 30.seconds, except: 'seconds')).to eq('2 hours and 30 minutes')
      end

      it 'except:seconds has higher precedence than include_seconds:true' do
        expect(distance_of_time(1.2.minute, include_seconds: true, except: 'seconds')).to eq('1 minute')
      end
    end
  end

  describe '#distance_of_time_in_words_hash' do
    describe 'giving correct numbers of' do
      %i[years months weeks days minutes seconds].each do |name|
        describe name do
          it 'exactly' do
            hash = distance_of_time_in_words_hash(START_TIME, START_TIME + 1.send(name))
            expect(hash[name]).to eq(1)
          end

          it 'two' do
            hash = distance_of_time_in_words_hash(START_TIME, START_TIME + 2.send(name))
            expect(hash[name]).to eq(2)
          end
        end
      end

      it 'should be happy with lots of measurements' do
        hash = distance_of_time_in_words_hash(
          START_TIME,
          START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds
        )
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

  describe '#time_ago_in_words' do
    it 'aliases to distance_of_time_in_words' do
      expect(time_ago_in_words(Time.now - 3.days - 14.minutes)).to eq('3 days and 14 minutes')
    end
  end

  describe '#distance_of_time_in_words' do
    context 'locale' do
      it 'includes known languages' do
        expect(DOTIW.languages).to include :en
        expect(DOTIW.languages).to include :ru
      end

      it 'includes all the languages in specs' do
        languages = Dir[File.join(File.dirname(__FILE__), 'i18n', '*.yml')].map { |f| File.basename(f, '.yml') }
        expect(DOTIW.languages.map(&:to_s).sort).to eq languages.sort
      end

      DOTIW.languages.each do |lang|
        context lang do
          YAML.safe_load(
            File.read(
              File.join(
                File.dirname(__FILE__), 'i18n', "#{lang}.yml"
              )
            )
          ).each_pair do |category, fixtures|
            context category do
              fixtures.each_pair do |k, v|
                it v do
                  expect(
                    distance_of_time_in_words(
                      START_TIME,
                      START_TIME + eval(k),
                      true,
                      locale: lang
                    )
                  ).to eq(v)
                end
              end
            end
          end
        end
      end
    end

    [
      [START_TIME, START_TIME + 5.days + 3.minutes, '5 days and 3 minutes'],
      [START_TIME, START_TIME + 1.minute, '1 minute'],
      [START_TIME, START_TIME + 3.years, '3 years'],
      [START_TIME, START_TIME + 10.years, '10 years'],
      [START_TIME, START_TIME + 8.months, '8 months'],
      [START_TIME, START_TIME + 3.hour, '3 hours'],
      [START_TIME, START_TIME + 13.months, '1 year and 1 month'],
      # Any numeric sequence is merely coincidental.
      [START_TIME, START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds, '1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds'],
      ['2009-3-16'.to_time, '2008-4-14'.to_time, '11 months and 2 days'],
      ['2009-3-16'.to_time + 1.minute, '2008-4-14'.to_time, '11 months, 2 days, and 1 minute'],
      ['2009-4-14'.to_time, '2008-3-16'.to_time, '1 year, 4 weeks, and 1 day'],
      ['2009-2-01'.to_time, '2009-3-01'.to_time, '1 month'],
      ['2008-2-01'.to_time, '2008-3-01'.to_time, '1 month'],
      [Date.parse('31.03.2015').to_time, Time.parse('01.03.2016'), '10 months, 4 weeks, and 2 days'],
      [Date.new(2014, 1, 31), Date.new(2014, 3, 1), '4 weeks and 1 day'],
      ['2008-2-01'.to_time, '2008-3-01'.to_time, '1 month'],
      ['2014-1-31'.to_time, '2014-3-01'.to_time, '4 weeks and 1 day'],
      ['2014-1-31'.to_time, '2014-3-02'.to_time, '4 weeks and 2 days'],
      ['2016-1-31'.to_time, '2016-3-01'.to_time, '4 weeks and 2 days'],
      ['2016-1-31'.to_time, '2016-3-02'.to_time, '1 month']
    ].each do |start, finish, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, true)).to eq(output)
        expect(distance_of_time_in_words(finish, start, true)).to eq(output)
      end
    end

    [
      [Time.zone.now, Time.zone.now + 1.day - 1.minute, '23 hours and 59 minutes'],
      [Time.zone.now, Time.zone.now + 15.days - 1.minute, '14 days, 23 hours, and 59 minutes'],
      [Time.zone.now, Time.zone.now + 29.days - 1.minute, '28 days, 23 hours, and 59 minutes'],
      [Time.zone.now, Time.zone.now + 30.days - 1.minute, '29 days, 23 hours, and 59 minutes'],
      [Time.zone.now, Time.zone.now + 31.days - 1.minute, '30 days, 23 hours, and 59 minutes'],
      [Time.zone.now, Time.zone.now + 32.days - 1.minute, '31 days, 23 hours, and 59 minutes'],
      [Time.zone.now, Time.zone.now + 33.days - 1.minute, '32 days, 23 hours, and 59 minutes']
    ].each do |start, finish, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, accumulate_on: 'days')).to eq(output)
      end
    end

    [
      [Time.at(1), Time.at(100), '1 minute'],
      [DateTime.now, DateTime.now + 1.minute, '1 minute'],
      [Date.new(2000, 1, 2), Date.new(2000, 1, 3), '1 day'],
      [Time.at(DateTime.now), DateTime.now + 1.minute, '1 minute']
    ].each do |start, finish, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish)).to eq(output)
      end
    end

    describe 'accumulate_on:' do
      [
        [START_TIME,
         START_TIME + 10.minute,
         :seconds,
         '600 seconds'],
        [START_TIME,
         START_TIME + 10.hour + 10.minute + 1.second,
         :minutes,
         '610 minutes and 1 second'],
        [START_TIME,
         START_TIME + 2.day + 10_000.hour + 10.second,
         :hours,
         '10048 hours and 10 seconds'],
        [START_TIME,
         START_TIME + 2.day + 10_000.hour + 10.second,
         :days,
         '418 days, 16 hours, and 10 seconds'],
        [START_TIME,
         START_TIME + 2.day + 10_000.hour + 10.second,
         :weeks,
         '59 weeks, 5 days, 16 hours, and 10 seconds'],
        [START_TIME,
         START_TIME + 2.day + 10_000.hour + 10.second,
         :months,
         '13 months, 3 weeks, 1 day, 16 hours, and 10 seconds'],
        ['2015-1-15'.to_time, '2016-3-15'.to_time, :months, '14 months']
      ].each do |start, finish, accumulator, output|
        it "should be #{output}" do
          expect(distance_of_time_in_words(start, finish, true, accumulate_on: accumulator)).to eq(output)
        end
      end
    end # :accumulate_on

    describe 'without finish time' do
      # A missing finish argument should default to zero, essentially returning
      # the equivalent of distance_of_time in order to be backwards-compatible
      # with the original rails distance_of_time_in_words helper.
      [
        [5.minutes.to_i, '5 minutes'],
        [10.minutes.to_i, '10 minutes'],
        [1.hour.to_i, '1 hour'],
        [6.days.to_i, '6 days'],
        [4.weeks.to_i, '4 weeks'],
        [24.weeks.to_i, '5 months, 2 weeks, and 1 day']
      ].each do |start, output|
        it "should be #{output}" do
          expect(distance_of_time_in_words(start)).to eq(output)
        end
      end
    end
  end

  describe 'with output options' do
    [
      # Any numeric sequence is merely coincidental.
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { words_connector: ' - ' },
       '1 year - 2 months - 3 weeks - 4 days - 5 hours - 6 minutes, and 7 seconds'],
      [START_TIME,
       START_TIME + 5.minutes + 6.seconds,
       { two_words_connector: ' - ' },
       '5 minutes - 6 seconds'],
      [START_TIME,
       START_TIME + 4.hours + 5.minutes + 6.seconds,
       { last_word_connector: ' - ' },
       '4 hours, 5 minutes - 6 seconds'],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.days + 4.hours + 5.minutes + 6.seconds,
       { except: 'minutes' },
       '1 year, 2 months, 3 days, 4 hours, and 6 seconds'],
      [START_TIME,
       START_TIME + 1.hour + 1.minute,
       { except: 'minutes' }, '1 hour'],
      [START_TIME,
       START_TIME + 1.hour + 1.day + 1.minute,
       { except: %w[minutes hours] },
       '1 day'],
      [START_TIME,
       START_TIME + 1.hour + 1.day + 1.minute,
       { only: %w[minutes hours] },
       '1 hour and 1 minute'],
      [START_TIME,
       START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { except: 'minutes' },
       '1 year, 2 months, 3 weeks, 4 days, 5 hours, and 7 seconds'],
      [START_TIME,
       START_TIME + 1.hour + 2.minutes + 3.seconds,
       { highest_measure_only: true },
       '1 hour'],
      [START_TIME,
       START_TIME + 1.hours + 2.minutes + 3.seconds,
       { highest_measures: 1 },
       '1 hour'],
      [START_TIME,
       START_TIME + 2.year + 3.months + 4.days + 5.hours + 6.minutes + 7.seconds,
       { highest_measures: 3 },
       '2 years, 3 months, and 4 days'],
      [START_TIME,
       START_TIME + 2.year + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
       { highest_measures: 2 },
       '2 years and 3 weeks'],
      [START_TIME,
       START_TIME + 4.days + 6.minutes + 7.seconds,
       { highest_measures: 3 },
       '4 days, 6 minutes, and 7 seconds'],
      [START_TIME,
       START_TIME + 1.year + 2.weeks,
       { highest_measures: 3 },
       '1 year and 2 weeks'],
      [START_TIME,
       START_TIME + 1.days,
       { only: %i[years months] },
       'less than 1 month'],
      [START_TIME,
       START_TIME + 5.minutes,
       { except: %i[hours minutes seconds] },
       'less than 1 day'],
      [START_TIME,
       START_TIME + 1.days,
       { highest_measures: 1, only: %i[years months] },
       'less than 1 month']
    ].each do |start, finish, options, output|
      it "should be #{output}" do
        expect(distance_of_time_in_words(start, finish, true, options)).to eq(output)
      end
    end

    if defined?(ActionView)
      describe 'ActionView' do
        [
          [START_TIME,
           START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
           { vague: true },
           'about 1 year'],
          [START_TIME,
           START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
           { vague: 'Yes please' },
           'about 1 year'],
          [START_TIME,
           START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
           { vague: false },
           '1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds'],
          [START_TIME,
           START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
           { vague: nil },
           '1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds']
        ].each do |start, finish, options, output|
          it "should be #{output}" do
            expect(distance_of_time_in_words(start, finish, true, options)).to eq(output)
          end
        end

        context 'via ActionController::Base.helpers' do
          it '#distance_of_time_in_words' do
            end_time = START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds
            expected = '1 year, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, and 7 seconds'
            actual = ActionController::Base.helpers.distance_of_time_in_words(START_TIME, end_time, true, { vague: false })
            expect(actual).to eq(expected)
          end

          it '#time_ago_in_words' do
            expected = '3 days and 14 minutes'
            actual = ActionController::Base.helpers.time_ago_in_words(Time.now - 3.days - 14.minutes)
            expect(actual).to eq(expected)
          end
        end
      end
    end

    describe 'include_seconds' do
      it 'is ignored if only seconds have passed' do
        expect(distance_of_time_in_words(START_TIME, START_TIME + 1.second, false)).to eq('1 second')
      end

      it 'removes seconds in all other cases' do
        expect(
          distance_of_time_in_words(
            START_TIME,
            START_TIME + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds,
            false
          )
        ).to eq('1 year, 2 months, 3 weeks, 4 days, 5 hours, and 6 minutes')
      end
    end # include_seconds
  end

  if defined?(ActionView)
    describe 'percentage of time' do
      def time_in_percent(options = {})
        distance_of_time_in_percent('04-12-2009'.to_time, '29-01-2010'.to_time, '04-12-2010'.to_time, options)
      end

      it 'calculates 15%' do
        expect(time_in_percent).to eq('15%')
      end

      it 'calculates 15.3%' do
        expect(time_in_percent(precision: 1)).to eq('15.3%')
      end
    end
  end
end
