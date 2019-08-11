FactoryGirl.define do

  factory :setting do
    site { |r| Site.first || r.association(:site) }
    name 'setting'

    factory :setting_site do
      value OpenStruct.new(publisher_site: {
        use_turbolinks: '',
        navigation_shop_ids: '',
        blog_link_title: '',
        blog_link_url: '',
        powered_by: '',
        show_news_popup_for_empty_shop: '',
        show_disclaimer: '',
        disclaimer_text: '',
        show_footer: '',
        show_social_media_column: '',
        currency_symbol_position: '',
        days_coupon_is_new: '',
        show_related_coupons: '',
        related_coupon_type: '',
        shop_pages_title_structure: '',
        home_breadcrumb_name: '',
        paginate_categories: 1,
        hide_expired_coupons: '',
        hide_star_rating: 2
      }.to_ostruct_recursive)
    end

    factory :setting_style do
      container_desktop 950
    end


    factory :setting_homepage do
      value OpenStruct.new( homepage:{
        title: 'my-title',
        meta_title: 'my-meta-title',
        meta_description: 'my-meta-description',
        meta_robots: 'my-meta-robots',
        head_scripts: 'my-head-scripts',
      }.to_ostruct_recursive )
    end

    factory :setting_legal_pages do
      value OpenStruct.new( legal_pages: {
        about_us_url: '/my-about-url',
        imprint_url: '/my-imprint-url',
        terms_and_conditions_url: '/my-terms-url',
        data_security_url: '/my-data-security-url',
        press_url: '/my-press-url',
      }.to_ostruct_recursive )
    end

    factory :setting_admin_rules do
      value OpenStruct.new( admin_rules: {
        canonical_domain: 'http://my-canonical-domain.com',
        dynamic_pages: 'my-dynamic-pages',
        static_pages: 'my-static-pages',
        robots_txt: 'my-robots-txt',
        explain_cookie_url: 'http://explain_cookie_url',
        show_cookie_law_message: 1
      }.to_ostruct_recursive )
    end

    factory :setting_routes do
      value OpenStruct.new( routes: {
      page_show: '',
      category: '',
      category_show: '',
      go_to_coupon: '',
      top_coupons: '',
      new_coupons: '',
      expiring_coupons: '',
      free_delivery_coupons: '',
      free_coupons: '',
      exclusive_coupons: '',
      campaign_page: '',
      shop_campaign_page: '',
      search_page: '',
      shop_index: '',
      shop_show: '',
      contact_form: '',
      partner_form: '',
      report_form: ''
      }.to_ostruct_recursive )
    end

    factory :setting_newsletter do
      value OpenStruct.new(newsletter: {
        mailchimp_api_key: '9x3xxx0xx850320x60xxx38x6x227xx76-us1',
        mailchimp_list_id: '265165135'
      }.to_ostruct_recursive)
    end

    factory :setting_affiliate_network do
      affilinet_publisher_id '1001'
      affilinet_publisher_web_service_password 'password'
    end
  end
end
