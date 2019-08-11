xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.google.com/schemas/sitemap/0.9 http://www.google.com/schemas/sitemap/0.9/sitemap.xsd" do

  if @index_dynamic_pages

    @site.shops.visible.indexed.each do |shop|
      xml.url do
        xml.loc send("shop_show_#{@site.site.id}_url", slug: shop.slug, only_path: false, host: @hostname)
        xml.lastmod shop.updated_at.present? ? shop.updated_at.strftime("%Y-%m-%d") : shop.created_at.strftime("%Y-%m-%d")
        xml.changefreq shop.sitemap_changefreq
        xml.priority shop.sitemap_priority
        if shop.logo.present?
          xml.image :image do |image|
            image.image :loc, shop.logo_url
          end
        end
      end
    end

    @site.categories.indexed.each do |category|
      xml.url do
        xml.loc send("category_show_#{@site.site.id}_url", slug: category.slug, only_path: false, host: @hostname)
        xml.lastmod category.updated_at.present? ? category.updated_at.strftime("%Y-%m-%d") : category.created_at.strftime("%Y-%m-%d")
        xml.changefreq 'monthly'
        xml.priority 0.2
      end
    end

    @site.campaigns.indexed.each do |campaign|
      xml.url do
        if campaign.shop_id.present?
          xml.loc send("shop_campaign_#{@site.site.id}_url", shop_slug: campaign.shop.slug, slug: campaign.slug, only_path: false, host: @hostname)
        else
          xml.loc send("campaign_show_#{@site.site.id}_url", slug: campaign.slug, only_path: false, host: @hostname)
        end
        xml.lastmod campaign.updated_at.present? ? campaign.updated_at.strftime("%Y-%m-%d") : campaign.created_at.strftime("%Y-%m-%d")
        xml.changefreq 'daily'
        xml.priority 0.4
      end
    end

    xml.url do
      xml.loc send("categories_index_#{@site.site.id}_url", only_path: false, host: @hostname)
      xml.changefreq 'monthly'
      xml.priority 0.2
    end
  end

  if @index_static_pages
    xml.url do
      xml.loc "#{hostname_with_protocol}"
      xml.changefreq 'daily'
      xml.priority 0.6
    end

    @site.static_pages.active.cleanup.each do |page|
      xml.url do
        xml.loc send("page_show_#{@site.site.id}_url", only_path: false, slug: page.slug, host: @hostname)
        xml.lastmod page.updated_at.present? ? page.updated_at.strftime("%Y-%m-%d") : page.created_at.strftime("%Y-%m-%d")
        xml.changefreq 'weekly'
        xml.priority 0.2
      end
    end
  end
end
