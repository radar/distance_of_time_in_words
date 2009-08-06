# dotiw

dotiw is a plugin for Rails that overrides the default `distance_of_time_in_words` and provides a more accurate output. This takes the same options plus an additional one on the end for passing options to the output (which uses `to_sentence`)

Currently it's broken for large (i.e. 10) values for years. Fixed in later versions.