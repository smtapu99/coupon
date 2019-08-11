xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.google.com/schemas/sitemap/0.9 http://www.google.com/schemas/sitemap/0.9/sitemap.xsd" do

  if @index_dynamic_pages
    xml.url do
      xml.loc send("categories_index_#{@site.site.id}_url", only_path: false, host: @hostname)
      xml.changefreq 'weekly'
      xml.priority 0.2
    end

    @site.categories.indexed.each do |category|
      xml.url do
        xml.loc send("category_show_#{@site.site.id}_url", slug: category.slug, only_path: false, host: @hostname)
        xml.lastmod category.updated_at.present? ? category.updated_at.iso8601 : category.created_at.iso8601
        xml.changefreq 'weekly'
        xml.priority 0.2
      end
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
        xml.lastmod page.updated_at.present? ? page.updated_at.iso8601 : page.created_at.iso8601
        xml.changefreq 'weekly'
        xml.priority 0.2
      end
    end
  end
end
