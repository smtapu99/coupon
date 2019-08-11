module WebpackHelper
  def webpack_asset_path filename, fallback
    if Webpacker.manifest.lookup(filename)
      asset_pack_url(filename)
    else
      asset_pack_url(fallback)
    end
  end

  def webpack_stylesheet_pack_tag filename, fallback
    if Webpacker.manifest.lookup(filename)
      stylesheet_pack_tag(filename)
    else
      stylesheet_pack_tag(fallback)
    end
  end

  def webpack_javascript_pack_tag filename, fallback
    if Webpacker.manifest.lookup(filename)
      javascript_pack_tag(filename)
    else
      javascript_pack_tag(fallback)
    end
  end

end

