## 5.4.0 (Next)

* [#131](https://github.com/radar/distance_of_time_in_words/pull/131): Deprecates `highest_measure_only`. Adds alternate form of `highest_measures` option to permit rounding up whatever part of the duration was previously silently discarded - [@seansfkelley](https://github.com/seansfkelley).
* [#133](https://github.com/radar/distance_of_time_in_words/pull/133): Test on Ruby 3.0 and 3.1 - [@dblock](https://github.com/dblock).
* [#134](https://github.com/radar/distance_of_time_in_words/pull/134): Add support for Dzongkha, the National language of Bhutan - [@KinWang-2013](https://github.com/KinWang-2013).
* [#135](https://github.com/radar/distance_of_time_in_words/pull/135): Add support for Ruby 2.7 and 3.2, removed support for ruby 2.4, 2.5, 2.6 and Rails 4 - [@KinWang-2013](https://github.com/KinWang-2013).
* [#136](https://github.com/radar/distance_of_time_in_words/pull/136): Add support for Rails 7 - [@KinWang-2013](https://github.com/KinWang-2013).
* [#139](https://github.com/radar/distance_of_time_in_words/pull/139): Fix bug with pluralization of Russian translations for numbers ending in 1 - [bitberry-dev](https://github.com/bitberry-dev).
* Your contribution here.

## 5.3.3 (2022/04/25)

* [#128](https://github.com/radar/distance_of_time_in_words/pull/128): Adds support for numeric values for both the `from_time` and `to_time` arguments in the `#distance_of_time_in_words` helper - [@bjedrocha](https://github.com/bjedrocha).

## 5.3.2 (2021/11/08)

* [#126](https://github.com/radar/distance_of_time_in_words/pull/126): Fixes `#distance_of_time_in_words_to_now` with `vague: true` when supplied without `include_seconds` argument - [@mozcomp](https://github.com/mozcomp).

## 5.3.1 (2021/03/26)

* [#124](https://github.com/radar/distance_of_time_in_words/pull/124): Fixes compact formatting for distance_of_time_in_words - [@rposborne](https://github.com/rposborne).

## 5.3.0 (2021/03/18)

* [#115](https://github.com/radar/distance_of_time_in_words/pull/115): Use constants for time durations (2x faster, 3.5x less memory) - [@krzysiek1507](https://github.com/krzysiek1507).
* [#117](https://github.com/radar/distance_of_time_in_words/pull/117): Support `#distance_of_time_in_words_to_now` with `vague: true` - [@joshuapinter](https://github.com/joshuapinter).
* [#118](https://github.com/radar/distance_of_time_in_words/pull/118): Raise `ArgumentError` when `nil` is passed for time, to match original `distance_of_time_in_words` - [@joshuapinter](https://github.com/joshuapinter).
* [#119](https://github.com/radar/distance_of_time_in_words/pull/119): Do not mutate input options - [@joshuapinter](https://github.com/joshuapinter).

## 5.2.0 (2020/10/03)

* [#94](https://github.com/radar/distance_of_time_in_words/pull/94): Add :compact formatting option - [@booty](https://github.com/booty).
* [#112](https://github.com/radar/distance_of_time_in_words/pull/112): Add Swedish language support - [@davidwessman](https://github.com/davidwessman).
* [#114](https://github.com/radar/distance_of_time_in_words/pull/114): Add Traditional Chinese (Taiwan) language support - [@sibevin](https://github.com/sibevin).

## 5.1.0 (2020/08/05)

* [#111](https://github.com/radar/distance_of_time_in_words/pull/111): Fix: `NoMethodError` when calling `ActionController::Base.helpers.distance_of_time_in_words` - [@denisahearn](https://github.com/denisahearn).
* [#106](https://github.com/radar/distance_of_time_in_words/pull/106): Add Vietnamese language support - [@runlevel5 ](https://github.com/runlevel5).

## 5.0.0 (2020/05/07)

* [#105](https://github.com/radar/distance_of_time_in_words/pull/105): Support for Ruby w/o Rails - [@dblock](https://github.com/dblock).
* [#108](https://github.com/radar/distance_of_time_in_words/pull/108): Fix negative weeks - [@ivanovaleksey](https://github.com/ivanovaleksey).

## 4.0.1 (2018/06/01)

## 3.1.1 (2016/03/08)

## 3.1.0 (2016/03/07)

* [#68](https://github.com/radar/dotiw/pull/68): Add support for weeks - [@lauranjansen](https://github.com/lauranjansen).
* [#69](https://github.com/radar/dotiw/pull/69): Add Indonesian language support - [@avidmaulanas](https://github.com/avidmaulanas).
* [#70](https://github.com/radar/dotiw/pull/70): Add French language support - [@geo1004](https://github.com/geo1004).
* [#72](https://github.com/radar/dotiw/pull/72): Add Danish language support - [@kaspernj](https://github.com/kaspernj).
* [#71](https://github.com/radar/dotiw/pull/71): Update bundler and ruby versions for Travis CI - [@lauranjansen](https://github.com/lauranjansen).

## 3.0.1 (2015/04/09)

## 3.0 (2015/04/09)

## 0.2.4 (2009/10/18)

* Initial public release - [@radar](https://github.com/radar).
