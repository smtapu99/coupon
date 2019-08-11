xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.google.com/schemas/sitemap/0.9 http://www.google.com/schemas/sitemap/0.9/sitemap.xsd" do

  if @index_dynamic_pages
    xml.url do
      xml.loc send("shops_index_#{@site.site.id}_url", only_path: false, host: @hostname)
      xml.changefreq 'weekly'
      xml.priority 0.2
    end
  end
  @site.shops.visible.indexed.each do |shop|
    xml.url do
      xml.loc send("shop_show_#{@site.site.id}_url", slug: shop.slug, only_path: false, host: @hostname)
      xml.lastmod shop.updated_at.present? ? shop.updated_at.iso8601 : shop.created_at.iso8601
      xml.changefreq shop.sitemap_changefreq
      xml.priority shop.sitemap_priority
      if shop.logo.present?
        xml.image :image do |image|
          image.image :loc, shop.logo_url
        end
      end
    end
  end
end
