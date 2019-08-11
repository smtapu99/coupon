
task :change_category_slugs => :environment do

  site_id = 32

  urls = [
['apprendimento','corsi'],
['casa-e-giardino','casa-giardino'],
['divertimento-e-tempo-libero','divertimento-tempo-libero'],
['gioielli-e-orologi','gioielli-orologi'],
['grandi-ecommerce','grandi-e-commerce'],
['regali-e-fiori','regali-fiori'],
['salute-e-bellezza','salute-bellezza'],
['scuola-e-ufficio','scuola-ufficio'],
['servizi-bancari-e-assicurativi','servizi-bancari-assicurativi'],
  ]

  categories = []
  redirects = []
  existing_redirects = []
  no_change = []
  blocked_categories = []
  subcat_redirects = []
  existing_subcat_redirects = []

  site = Site.find(site_id)
  root_dir = '/' + (site.setting.routes.application_root_dir.present? ? site.setting.routes.application_root_dir.gsub('/', '') : '')

  urls.each do |slug|
    if slug[0] == slug[1]
      no_change << slug
      next
    end

    begin
      category = Category.find_by(slug: slug[0], site_id: site.id)

      category.slug = slug[1]
      category.slug_mutable = 1
      categories << category

      unless category.present?
        blocked_categories << slug
        next
      end

      category.sub_categories.each do |subcat|

        old_url = send("subcategory_show_#{site_id}_path", slug: subcat.slug, parent_slug: slug[0])
        new_url = send("subcategory_show_#{site_id}_path", slug: subcat.slug, parent_slug: slug[1])

        existing_subcat_redirects << subcat.current_redirects_for(new_url, old_url)
        rule = RedirectRule.new(
          site_id: site.id,
          source: old_url,
          destination: new_url,
          active: 1,
          request_environment_rules:
          [RequestEnvironmentRule.new(environment_key_name: 'SERVER_NAME',environment_value: site.hostname.dup)]
        );

        subcat_redirects << rule
      end

      if category.parent.present?
        old_url = send("subcategory_show_#{site_id}_path", slug: slug[0], parent_slug: category.parent.slug)
        new_url = send("subcategory_show_#{site_id}_path", slug: slug[1], parent_slug: category.parent.slug)
      else
        old_url = send("category_show_#{site_id}_path", slug: slug[0])
        new_url = send("category_show_#{site_id}_path", slug: slug[1])
      end

      existing_redirects << category.current_redirects_for(new_url, old_url) # find reverse redirects

      rule = RedirectRule.new(
        site_id: site.id,
        source: old_url,
        destination: new_url,
        active: 1,
        request_environment_rules:
        [RequestEnvironmentRule.new(environment_key_name: 'SERVER_NAME',environment_value: site.hostname)]
      );

      redirects << rule

    rescue Exception => e
      binding.pry
    end

  end

  binding.pry

end

# existing_redirects.reject(&:empty?).flatten.map(&:destroy)
# existing_categorie_redirects.reject(&:empty?).flatten.map(&:destroy)
# categorie_redirects.map(&:save)
# redirects.map(&:save)
# categories.map(&:save)
























































































