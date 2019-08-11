class Theme

  def self.current
    RequestStore.store[:theme_current]
  end

  def self.current=(theme)
    RequestStore.store[:theme_current] = theme
  end

end
