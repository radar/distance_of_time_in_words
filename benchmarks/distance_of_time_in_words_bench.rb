# frozen_string_literal: true

# Benchmark for https://github.com/radar/distance_of_time_in_words/issues/79
#
# Compares dotiw's distance_of_time_in_words against Rails' original
# ActionView::Helpers::DateHelper#distance_of_time_in_words, using the
# scenario from the issue and its follow-up comments.
#
# Run with `ruby benchmarks/distance_of_time_in_words_bench.rb` after
# `gem install benchmark-ips benchmark-memory actionview`.

require 'active_support'
require 'active_support/core_ext'
require 'benchmark/ips'
require 'benchmark/memory'

require_relative '../lib/dotiw'

begin
  require 'action_view'
rescue LoadError
  warn "This benchmark requires actionview: gem install actionview"
  exit 1
end

include ActionView::Helpers::DateHelper

now = Time.now
future_time = Time.now + 100.years + 30.days + 50.seconds

%i[ips memory].each do |type|
  Benchmark.public_send(type) do |x|
    x.report('dotiw') { DOTIW.distance_of_time_in_words(now, future_time) }
    x.report('rails') { distance_of_time_in_words(now, future_time, include_seconds: true) }

    x.compare!
  end
end
