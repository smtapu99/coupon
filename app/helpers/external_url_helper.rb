module ExternalUrlHelper

  def cloak_urls value
    cloacked_markup = Rails.cache.fetch([@site.site.id, 'cloaked_urls', Digest::MD5.hexdigest(value.to_s)]) do
      doc = Nokogiri::HTML(value)
      doc.xpath('//comment()').remove
      doc.css("a").each do |link|

        url = link.attributes["href"].value if link.attributes['href'].present?
        next if url.blank? || external_url_allowed?(url) || link.attributes['data-allowed'].present?

        cloacked_url = cloak_url_string url
        link.set_attribute('href', cloacked_url)
        link.set_attribute('rel', 'nofollow')
        link.set_attribute('target', '_blank')
      end

      doc.css('body').inner_html.to_s
    end
  end

  def cloak_url_string url
    return url unless @site.present?

    external_url_id = Rails.cache.fetch([Site.current.id, 'ext_url', url], expires_in: 30.days) do
      ExternalUrl.find_or_create_by(site_id: @site.site.id, url: url).id
    end

    if external_url_id.present?
      return "#{root_path.chomp('/')}/out/#{external_url_id}"
    end

    # fallback in case anything goes wrong with cloaking keep the old url working
    url
  end

  def external_url_allowed? url
    allowed_url_hostnames.include? URI.parse(sanitize_url_or_path(url)).host rescue false
  end

  def sanitize_url_or_path url
    return nil if url.blank?

    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      return "http://#{@site.site.hostname}/#{url.gsub(/^\//, '')}"
    end
    url
  end

  private

  def allowed_url_hostnames
    @allowed_url_hostnames ||= Site.all.pluck(:hostname)
  end
end
