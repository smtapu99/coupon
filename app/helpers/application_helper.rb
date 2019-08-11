module ApplicationHelper
  def default_robots_txt
    robots = "User-agent: *\n"
    robots += "Disallow: #{URI.parse(dynamic_url_for('coupon', 'clickout', 1)).path.gsub!(/1/, '*')}\n"
    robots += "Disallow: /out/*\n"
    robots += "Disallow: /OUT/*\n"
    robots += "Disallow: /Out/*\n"
    robots += "Disallow: #{dynamic_url_for('search', 'index', only_path: true)}?*\n"
    robots += "Disallow: /*?*theme*\n"
    robots += "Disallow: /*?*Theme*\n"
    robots += "Disallow: /*?*PageSpeed*\n"
    robots += "Disallow: /*?*Pagespeed*\n"
    robots += "Disallow: /*?*pagespeed*\n"
    robots += "Disallow: /*?*Custom*\n"
    robots += "Disallow: /*?*custom*\n"
    robots += "Disallow: /*?*ModPagespeed*\n"
    robots += "Disallow: /*?*modpagespeed*\n"
    robots += "Disallow: /*?*Modpagespeed*\n"
    robots += "Disallow: /*?*modPagespeed*\n"
    robots += "Disallow: /*?*replytocom*\n"
    robots += "Disallow: /*?*shop_slug*\n"
    robots += "Disallow: /*?*parent_slug*\n"
    robots += "Disallow: /*?*slug*\n"
    robots += "Disallow: /ajaxs/*\n"
    robots += "Disallow: /deals/*\n"
    robots
  end

  def newsletter_enabled?
    @newsletter_enabled ||= Setting::get('newsletter.newsletter_enabled', default: 1).to_i == 1 \
      && Setting::get('newsletter.mailchimp_api_key').present? \
      && Setting::get('newsletter.mailchimp_list_id').present?
  end

  def translate_from_file(key, opts = {})
    I18n.global_scope = :backend
    translation = I18n.t(key, opts)
    I18n.global_scope = :frontend
    translation
  end

  def set_global_surrogate_key
    response.headers['Surrogate-Key'] = [response.headers['Surrogate-Key'], Site.current.surrogate_key].reject(&:blank?).join(' ') if Setting::get('caching.use_surrogate_keys').to_i === 1
  end

  def surrogate_key_header(*keys)
    response.headers['Surrogate-Key'] = [response.headers['Surrogate-Key'], *keys].reject(&:blank?).join(' ') if Setting::get('caching.use_surrogate_keys').to_i === 1
  end

  def hero_links
    hero_link_setting = Setting.get('publisher_site.hero_links')
    if hero_link_setting.present?
      hero_link_setting.split("\n").map do |link|
        formatted_link = link.split('|')
        {
          link_text: formatted_link.first.strip,
          link_url: formatted_link.last.strip
        }
      end
    end
  end

  def reduced_js_features?
    return @reduced_js_features unless @reduced_js_features.nil?
    @reduced_js_features = Setting::get('publisher_site.reduced_js_features', default: 0).to_i == 1
  end

  # this makes sure that the widget looks good in all resolutions. specially in tablet view it
  # is necessary to hide some elements so that the html doesnt break
  def hide_featured_class(values)
    positions = values[:teaser_positions].reject(&:empty?)

    case
    when positions.count == 3 || positions.count.zero?
      'hide-last-featured'
    when positions.count >= 2 && values[:ad_code].present?
      'hide-last-featured'
    when positions.count == 1 && positions.include?('3')
      'hide-third-featured'
    when positions.count == 1 && values[:ad_code].present? && positions.include?('3')
      'hide-last-featured'
    when positions.count == 2 && !values[:ad_code].present? && !positions.include?('5')
      'hide-first-featured'
    when positions.count == 2 && !values[:ad_code].present? && !positions.include?('1')
      'hide-last-featured'
    end
  end

  def sanitize_robots(robots)
    unwanted = %w[theme modpagespeed pagespeed custom shop_slug parent_slug slug replytocom]

    if request.query_parameters.present? && request.query_parameters.keys.select{ |k| unwanted.include?(k.to_s.downcase) }.any?
      return 'noindex, nofollow'
    end

    robots
  end

  def widget_expires_at(interval)
    case interval
    when 'daily'
      (Time.zone.now + 1.day).to_date.to_s
    when 'weekly'
      (Time.zone.now + 1.week).to_date.to_s
    when 'monthly'
      (Time.zone.now + 1.month).to_date.to_s
    else
      (Time.zone.now + 10.years).to_date.to_s
    end
  end

  def body_classes(classes=nil)
    classes_array = [Rails.application.class.to_s.split('::').first.downcase]
    classes_array << controller.controller_name
    classes_array << controller.action_name
    classes_array << 'no-topbar' if Setting::get('publisher_site.show_topbar', default: 1).to_i == 0
    classes_array << 'no-tracking' if controller.controller_name == 'pages' && %w[header footer].include?(controller.action_name)
    classes_array << 'only-content' if params[:only_content].present?

    unless classes.nil?
      method = classes.is_a?(Array) ? :concat : :<<
      classes_array.send method, classes
    end

    classes_array.join(' ')
  end

  def body_js_init
    controller.controller_name + '_' + controller.action_name
  end

  def original_url_with_custom_protocol
    "#{hostname_with_protocol}#{request.fullpath}"
  end

  def hostname_with_protocol
    "#{Site.current.protocol}://#{request.host}"
  end

  def is_home?
    params[:controller] == 'home' && params[:action] == 'index'
  end

  def is_shop?
    params[:controller] == 'shops' && params[:action] == 'show'
  end

  # this is to overwrite the default root_url method as we might have multiple root urls in different subdirs
  def root_url
    url_for(send("root_#{Site.current.id}_url"))
  end

  # this is to overwrite the default root_path method as we might have multiple root paths in different subdirs
  def root_path
    url_for(send("root_#{Site.current.id}_path"))
  end

  def dynamic_url_for(controller = nil, action = 'index', options = {})
    raise "Invalid path to action #{action}; ID is required!" if options.blank? and ['show', 'clickout'].include?(action)

    site = site_of_facade_or_current_site

    return root_url if controller == 'home' && action == 'index'

    opts = {}

    case options
    when Hash
      # symbolyze the keys of the hash to make sure they overwrite the defaults
      opts = options.symbolize_keys
      #TODO: make only_path false by default
      opts[:only_path] = !options[:only_path].nil? ? options[:only_path] : true
    when String
      if options.is_number?
        opts[:id] = options
      else
        opts[:slug] = options
      end
      opts[:only_path] = true
    when Integer
      opts[:id] = options
    else
      raise ArgumentError, 'options can be Hash, Integer or String'
    end

    case action
    when 'show'
      if controller.singularize == 'category' && options[:parent_slug].present?
        send("subcategory_show_#{site.id}_url", opts)
      else
        send("#{controller.singularize}_#{action}_#{site.id}_url", opts)
      end
    when 'clickout'
      send("#{controller.singularize}_#{action}_#{site.id}_url", opts)
    when 'index'
      if opts.present? && opts[:type].present?
        send("#{controller.pluralize}_#{opts[:type]}_#{site.id}_url", opts)
      else
        send("#{controller.pluralize}_index_#{site.id}_url", opts)
      end
    else
      send("#{controller.pluralize}_#{action}_#{site.id}_url", opts)
    end
  end

  def dynamic_campaign_url_for(campaign, opts = {})
    raise 'Invalid Campaign' unless campaign.is_a? Campaign

    opts[:only_path] ||= false
    opts[:slug] = campaign.slug
    opts[:parent_slug] = campaign.parent_slug if campaign.parent_slug.present?
    opts[:shop_slug] = campaign.shop_slug if campaign.shop_slug.present?

    if campaign.is_root_campaign?
      send("root_campaign_#{campaign.id}_url", opts)
    elsif campaign.template == 'sem'
      send("campaign_sem_#{campaign.site_id}_url", opts)
    elsif campaign.parent_id.present?
      send("campaign_sub_page_#{campaign.site_id}_url", opts)
    elsif campaign.shop_id.present?
      send("shop_campaign_#{campaign.site_id}_url", opts)
    else
      dynamic_url_for('campaign', 'show', opts)
    end
  end

  def operator_dropdown(model, name, html_class='form-control')
    push = <<-EOS
    <select id="#{model}_#{name}" name="#{model}[#{name}]" class="#{html_class}">
      <option value=""></option>
      <option value=">">></option>
      <option value="<"><</option>
      <option value="=">==</option>
      <option value=">=">>=</option>
      <option value="<="><=</option>
    </select>
    EOS
    push.html_safe
  end

  def alert_class(key)
    case key
    when :notice
      'alert-success'
    when :error
      'alert-danger'
    else
      'alert-info'
    end
  end

  def month_number_to_word(month = 1)
    @months ||= {}
    case month.to_i
    when 1
      @months['january'] ||= I18n.t(:JANUARY, default: 'January')
    when 2
      @months['february'] ||= I18n.t(:FEBRUARY, default: 'February')
    when 3
      @months['march'] ||= I18n.t(:MARCH, default: 'March')
    when 4
      @months['april'] ||= I18n.t(:APRIL, default: 'April')
    when 5
      @months['may'] ||= I18n.t(:MAY, default: 'May')
    when 6
      @months['june'] ||= I18n.t(:JUNE, default: 'June')
    when 7
      @months['july'] ||= I18n.t(:JULY, default: 'July')
    when 8
      @months['august'] ||= I18n.t(:AUGUST, default: 'August')
    when 9
      @months['september'] ||= I18n.t(:SEPTEMBER, default: 'September')
    when 10
      @months['october'] ||= I18n.t(:OCTOBER, default: 'October')
    when 11
      @months['november'] ||= I18n.t(:NOVEMBER, default: 'November')
    else
      @months['december'] ||= I18n.t(:DECEMBER, default: 'December')
    end
  end

  def render_critical_css
    # return "" if Rails.env.development?

    c_name = controller.controller_name
    c_action = controller.action_name

    out = '<style type="text/css">'

    case true
    when response.status.to_s == '404'
      out += render 'critical_css/shops_show.css'

    when c_name == 'shops' && c_action == 'index'
      out += render 'critical_css/shops_index.css'

    when c_name == 'categories' && c_action == 'index'
      out += render 'critical_css/categories_index.css'

    when c_name == 'coupons' && c_action == 'index'
      out += render 'critical_css/coupons_index.css'

    when c_name == 'categories' && c_action == 'show'
      out += render 'critical_css/categories_show.css'

    when c_name == 'shops' && c_action == 'show'
      out += render 'critical_css/shops_show.css'

    when c_name == 'campaigns' && c_action == 'show'
      out += render 'critical_css/campaigns_show.css'

    when c_name == 'campaigns' && c_action == 'sem'
      out += render 'critical_css/campaigns_show.css'

    when c_name == 'pages' && c_action == 'show'
      out += render 'critical_css/pages_show.css'

    when c_name == 'searches' && c_action == 'index'
      out += render 'critical_css/categories_show.css'

    when c_name == 'coupons' && c_action == 'clickout'
      out += render 'critical_css/coupons_clickout.css'

    when c_name == 'frontend' && c_action == 'not_found'
      out += render 'critical_css/shops_show.css'

    when c_name == 'bookmarks' && c_action == 'index'
      out += render 'critical_css/shops_show.css'

    else
      out += render 'critical_css/home.css'
    end

    out += '</style>'

    out.html_safe
  end

  def render_webpacked_critical_css
    out = '<style type="text/css">'

    css_dir = "public/packs/#{Site.current.id}/"
    css_fallback_dir = "public/packs/"

    critical_css = ["common.css"]

    c_name = controller.controller_name
    c_action = controller.action_name

    case true
    when response.status.to_s == '404'
      critical_css.push("sidebar.css", "coupon.css")

    when c_name == 'shops' && c_action == 'index'
      critical_css.push("sidebar.css", "popular-shops.css", "filter-by-category.css", "shop-index.css")

    when c_name == 'categories' && c_action == 'index'
      critical_css.push("categories.css")

    when c_name == 'coupons' && c_action == 'index'
      critical_css.push("sidebar.css", "coupon.css", "filter-by-type.css")

    when c_name == 'categories' && c_action == 'show'
      critical_css.push("sidebar.css", "featured-shops.css", "coupon.css", "shop-filter.css")

    when c_name == 'shops' && c_action == 'show'
      critical_css.push("sidebar.css", "coupon.css")

    when c_name == 'campaigns' && c_action == 'show'
      critical_css.push("campaigns.css")

    when c_name == 'campaigns' && c_action == 'sem'
      critical_css.push("campaigns.css", "sem.css")

    when c_name == 'pages' && c_action == 'show'
      critical_css.push("page.css", "sidebar.css")

    when c_name == 'searches' && c_action == 'index'
      critical_css.push("sidebar.css", "coupon.css")

    when c_name == 'coupons' && c_action == 'clickout'
      ##out += render 'critical_css/coupons_clickout.css'

    when c_name == 'frontend' && c_action == 'not_found'
      critical_css.push("sidebar.css", "coupon.css")

    when c_name == 'bookmarks' && c_action == 'index'
      ##out += render 'critical_css/shops_show.css'

    when c_name == 'mail_forms'
      critical_css.push("page.css", "mail-form.css", "sidebar.css")

    else
      critical_css.push("home.css", "featured-shops.css")
    end

    critical_css.each do |css|
      main_css = css_dir + css
      fallback_css = css_fallback_dir + css

      if File.exists?(main_css)
        out += File.read(main_css)
      elsif File.exists?(fallback_css)
        out += File.read(fallback_css)
      end
    end

    out += '</style>'

    out.html_safe
  end

  def search_box_placeholder_shops
    shop_ids = Setting::get('homepage.search_box_shops', default: nil)
    shops = @site.shops.where(id: shop_ids)
    return 'Amazon, Ebay, Nike' unless shops.present?

    shops.map(&:title).join(', ')
  end

  def search_box_shops_popular
    shop_ids = Setting::get('homepage.search_box_shops_popular', default: nil)
    @site.shops.where(id: shop_ids) if shop_ids.present?
  end

  def policy_url
    Setting::get('legal_pages.privacy_policy_url')
  end

  def cookie_url
    @cookie_url ||= Setting::get('admin_rules.cookie_policy_url')
  end

  private

  def site_of_facade_or_current_site
    return @site.site if @site.is_a?(SiteFacade)

    Site.current
  end
end
