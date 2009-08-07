class I18n
  def p(key)
    t(key, :default => key)
  end
end