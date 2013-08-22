# encoding: utf-8
# author: FloHin
# helper to store some useful methods for DOTIW classes

module DOTIW

  class Helper
    def self.i18n_t(name, fallback = nil)

      # set fallback if empty
      # assume name is a symbol and set string
      dfallback = name.to_s if fallback.nil?
      return I18n.t(name, :default => fallback)
    end
  end

end