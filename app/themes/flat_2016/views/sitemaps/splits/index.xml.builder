xml.instruct!
xml.sitemapindex "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  if @index_dynamic_pages
    ['shops', 'campaigns'].each do |type|
      next if type == 'campaigns' && !@site.campaigns.indexed.any?

      xml.sitemap do
        xml.loc send("sitemaps_type_#{@site.site.id}_url", type: type, only_path: false, host: @hostname)
        xml.lastmod type == 'shops' ? Time.zone.now.beginning_of_hour.iso8601 : Time.zone.now.beginning_of_day.iso8601
      end
    end
  end

  ['misc'].each do |type|
    xml.sitemap do
      xml.loc send("sitemaps_type_#{@site.site.id}_url", type: type, only_path: false, host: @hostname)
      xml.lastmod type == 'shops' ? Time.zone.now.beginning_of_hour.iso8601 : Time.zone.now.beginning_of_day.iso8601
    end
  end
end
