# frozen_string_literal: true

require 'benchmark/ips'
require 'benchmark/memory'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/integer'

require_relative '../lib/dotiw/time_hash'

from = Time.now
to = Time.now + 1.year + 2.months + 3.weeks + 4.days + 5.hours + 6.minutes + 7.seconds

%i[ips memory].each do |type|
  Benchmark.public_send(type) do |x|
    x.report('master') { DOTIW::TimeHash.new(nil, from, to) }

    x.compare!
  end
end
