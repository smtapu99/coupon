xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.google.com/schemas/sitemap/0.9 http://www.google.com/schemas/sitemap/0.9/sitemap.xsd" do

  @site.campaigns_for_sitemap.each do |campaign|
    next if campaign.has_inactive_parent?

    xml.url do
      xml.loc dynamic_campaign_url_for(campaign, host: @hostname)
      xml.lastmod campaign.updated_at.present? ? campaign.updated_at.iso8601 : campaign.created_at.iso8601
      xml.changefreq 'daily'
      xml.priority campaign.sitemap_priority
    end
  end
end
