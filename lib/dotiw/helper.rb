# encoding: utf-8
# author: FloHin
# helper to store some useful methods for DOTIW classes

module DOTIW

  class Helper

    # simply choose the translation tag with a default
    def self.i18n_t(name, fallback = nil)
      # set fallback if empty
      # assume name is a symbol and set string
      dfallback = name.to_s if fallback.nil?
      return I18n.t(name, :default => fallback)
    end

    def self.singular_plural_key(measure, key, count = 1)
      #first: check if there is a x_key one/other styled key
      x_key = "x_#{measure.to_s}".to_sym
      if exist_x_key? x_key

        return I18n.t x_key, :count => count
      else
        if count == 1
          # old DOTIW behaviour: defaults to key.singularize
          return key.singularize
        else
          # old DOTIW behaviour: suppose that key is aldready in plural
          return key
        end
      end
    end

    def self.singularize( measure, key)
      return self.singular_plural_key measure, key, count = 1
    end

    def self.pluralize( measure, key)
      return self.singular_plural_key measure, key, count = 2
    end

    def self.exist_x_key?(key)
      bla = I18n.t(x_key, :default => '', :raise => true) rescue false
      if bla.blank?
        return false
      else
        return true
      end
    end

  end
end
