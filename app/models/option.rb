class Option < ApplicationRecord
  # after_find :change_to_struct
  # before_save :change_to_hash

  OPTIONS = {
    :empty => {
      'Please select' => ''
    },
    :yes_or_no => {
      'Yes' => 1,
      'No'  => 0
    },
    :shop_tier_groups => {
      '1' => 1,
      '2' => 2,
      '3' => 3,
      '4' => 4
    },
    :follow => {
      'follow' => '', #follow is default
      'nofollow' => 'nofollow'
    },
    :summary_widget => {
      'Best Deals Summary' => 'best_deals_summary',
      'Best Deals Summary Advanced' => 'best_deals_summary_advanced',
      'Best Deals Summary Advanced Code' => 'best_deals_summary_advanced_code',
      'Coupons Summary' => 'coupons_summary',
      'Best Deals & Coupons Summary' => 'best_deals_and_coupons_summary'
    },
    :robots => {
      'index,follow' => 'index,follow',
      'noindex,nofollow' => 'noindex,nofollow',
      'noindex,follow' => 'noindex,follow',
      'index,nofollow' => 'index,nofollow'
    },
    :order_direction => {
      'ascending' => 'asc',
      'descending' => 'desc'
    },
    :background_repeat => {
      'repeat' => 'repeat',
      'repeat-x' => 'repeat-x',
      'repeat-y' => 'repeat-y',
      'no-repeat' => 'no-repeat'
    },
    :background_size => {
      'normal' => 'auto',
      'cover' => 'cover',
      'contain' => 'contain',
    },
    :banner_types => {
      'Sticky Banner' => 'sticky_banner',
      'Shop Banner' => 'shop_banner',
      'Sidebar Banner' => 'sidebar_banner',
    },
    :background_position => {
      'normal' => 'auto',
      'fixed' => 'fixed',
      'x: center y: center' => 'center center',
      'x: center y: top' => 'center top',
    },
    :background_default_color_names => {
      'Cloud' => 'cloud',
      'Ready' => 'ready',
      'Sky' => 'sky',
      'Mamba' => 'mamba',
      'Royal' => 'royal',
      'Freedom' => 'freedom',
      'Gold' => 'gold',
      'Juicy' => 'juicy',
    },
    :icons_default_names => {
      'Envelope' => 'envelope',
      'Crown' => 'crown',
      'Cart' => 'cart',
      'Search' => 'search',
      'Filter' => 'filter',
      'Coupons' => 'coupons',
      'Bubble' => 'bubble',
      'Group' => 'group',
      'Tag' => 'tag',
      'Category' => 'category',
      'Shops' => 'shops',
    },
    :icons_nav_names => {
      'Home' => 'home-nav',
      'Categories' => 'categories-nav',
      'Shops' => 'shops-nav',
      'Coupons' => 'coupon-nav',
      'Heart' => 'heart-nav'
    },
    :category_css_icon_classes => {
      'music' =>'music',
      'adults' =>'adults',
      'fashion' =>'fashion',
      'shoe' => 'shoe',
      'hobby' =>'hobby',
      'home' =>'home',
      'office' =>'office',
      'event-ticket' =>'event-ticket',
      'internet' =>'internet',
      'toys' =>'toys',
      'technology' =>'technology',
      'china-bazaar' =>'china-bazaar',
      'photo' =>'photo',
      'banking' =>'banking',
      'cars' =>'cars',
      'travel' =>'travel',
      'books' =>'books',
      'health' =>'health',
      'live-shopping' =>'live-shopping',
      'dating' =>'dating',
      'pets' =>'pets',
      'eating' =>'eating',
      'gifts' =>'gifts',
      'beauty' =>'beauty',
      'bio' =>'bio',
      'sport' =>'sport',
      'babies' =>'babies',
      'family' =>'family',
      'games' =>'games',
      'four-chips' => 'four-chips',
      'eyeglasses' => 'eyeglasses',
      'full-bed' => 'full-bed',
      'smartphone' => 'smartphone',
      'car' => 'car',
      'laptop' => 'laptop',
      'monitor' => 'monitor',
      'supermarket' => 'supermarket',
      'department-store' => 'department-store'

    },
    :import_settings => {
      'active' => 'active',
      'pending' => 'pending'
    },
    :navigation_settings => {
      'Fixed' => 'fixed',
      'Fullsize' => 'fullsize'
    },
    :related_coupons_settings => {
      'Related Coupons' => 'related',
      'Related Top Coupons' => 'top',
      'Most clicked Coupons' => 'most_clicked'
    },
    :indexation_rules_settings => {
      'Index + Canonical' => 'index_plus_canonical',
      'No Index' => 'noindex',
    },
    :coupon_types => {
      'Coupon' => 'coupon',
      'Offer' => 'offer',
    },
    :static_page_status => {
       'active' => 'active',
       'blocked' => 'blocked'
    },
    :user_status => {
       'active' => 'active',
       'blocked' => 'blocked'
    },
    :active_inactive => {
       'active' => 'active',
       'inactive' => 'inactive'
    },
    :campaign_template => {
       'default' => 'default',
       'grid' => 'grid',
       'Themed - Black Friday' => 'themed--black-friday',
       'Themed - Black Friday 2018' => 'themed--black-friday-2018',
       'Themed - Cyber Monday' => 'themed--cybermonday',
       'Themed' => 'themed--default',
       'SEM' => 'sem'
    },
    :coupon_savings_in => {
      'percent' => 'percent',
      'currency' => 'currency'
    },
    :featured_coupons_types => {
      'Last Chance' => 'last_chance',
      'Top Coupons' => 'top_coupons',
      'Exclusive Coupons' => 'exclusive_coupons'
    },
    :coupon_order_by => {
      'ID' => 'id',
      'Title' => 'title',
      'Top' => 'is_top',
      'Exclusive' => 'is_exclusive',
      'Free' => 'is_free',
      'Start Date' => 'start_date',
      'End Date' => 'end_date',
      'Updated At' => 'updated_at',
      'Shop ID' => 'shop_id',
      'Shop Title' => 'shop_title',
      'Category ID' => 'category_id'
    },
    :reverse_proxy_type => {
      'Varnish' => 'varnish',
      'Fastly (service)'  => 'fastly',
      'Cloudflare'  => 'cloudflare',
    },
    :themes => {
      'Flat 2016' => 'flat_2016',
      'Rebatly Flat' => 'rebatly_flat',
      'Flat 2016 Webpacked' => 'flat_2016_webpacked',
      'Simple 2019' => 'simple_2019'
    },
    :delivery_methods => {
      'DHL' => 'dhl',
      'DPD' => 'dpd',
      'HERMES' => 'hermes',
      'UPS' => 'ups',
      'FedEx' => 'fed_ex',
      'KURIER' => 'kurier',
      'TNT' => 'tnt',
      'EMS' => 'ems',
      'TOLL' => 'toll',
      'e-EMS' => 'e_ems',
      'ePacket' => 'e_packet',
      'China Post Registered Air Mail' => 'china_post_registered_air_mail',
      'China Post Air Parcel' => 'china_post_air_parcel',
      'China Post Ordinary Small Packet Plus' => 'china_post_ordinary_small_packet_plus',
      'HongKong Post Air Mail' => 'hong_kong_post_air_mail',
      'HongKong Post Air Parcel' => 'hong_kong_post_air_parcel',
      'Singapore Post' => 'singapore_post',
      'Swiss Post' => 'swiss_post',
      'Sweden Post' => 'sweden_post',
      'Russian Air' => 'russian_air',
      'Special Line-YW' => 'special_line_y_w',
      'DHL Global Mail' => 'dhl_global_mail',
      'S.F. Express' => 's_f_express',
      'SDA' => 'sda',
      'GLS' => 'gls',
      'Bartolini' => 'bartolini',
      'Poste Italiane' => 'poste_italiane',
      'Poczta Polska' => 'poczta_polska',
      'InPost' => 'in_post',
      'Sailpost' => 'sailpost',
      'Kurier K-ex' => 'kurier_k_ex',
      '4.72' => '4_72',
      'BlueExpress' => 'blue_express',
      'Castores' => 'castores',
      'Chilexpress' => 'chilexpress',
      'China Post Registered Air' => 'china_post_registered_air',
      'Coordinadora' => 'coordinadora',
      'Correos de Chile' => 'correos_de_chile',
      'Envía' => 'env_a',
      'Estafeta' => 'estafeta',
      'Metropolitana' => 'metropolitana',
      'Saferbo' => 'saferbo',
      'Servientrega' => 'servientrega',
      'TCC' => 'tcc',
      'Thomas' => 'thomas',
      'TransAtenas' => 'trans_atenas',
      'SEUR' => 'seur',
      'Zeleris' => 'zeleris',
      'PostNL' => 'postnl',
      'sandd' => 'sandd',
      'Mondial Relay' => 'mondial_relay',
      'Colissimo' => 'colissimo',
      'La Poste' => 'la_poste',
      'Russian Post' => 'russian_post',
      'Kiosk ruchu' => 'kiosk_ruchu',
      'USPS' => 'usps',
      'AMZL US (Amazon Logistics)' => 'amzl_us'
    },
    :payment_methods => {
      'PayPal' => 'pay_pal',
      'VISA' => 'visa',
      'MasterCard' => 'master_card',
      'American Express' => 'american_express',
      'VISA Electron' => 'visa_electron',
      'Diners Club' => 'diners_club',
      'Maestro' => 'maestro',
      'Cirrus' => 'cirrus',
      'GiroPay' => 'giro_pay',
      'QIWI Wallet' => 'qiwi_wallet',
      'WESTERN UNION' => 'western_union',
      'Bank Transfer' => 'bank_transfer',
      'Boleto Bancário' => 'boleto_banc_rio',
      'WebMoney' => 'web_money',
      'Yandex Money' => 'yandex_money',
      'Alipay' => 'alipay',
      'Postepay' => 'postepay',
      'Prepagate Paypal' => 'prepagate_paypal',
      'Carta Si' => 'carta_si',
      'Przelewy24.pl' => 'przelewy24_pl',
      'eCard' => 'e_card',
      'PayU' => 'pay_u',
      'DotPay' => 'dot_pay',
      'Cash on delivery' => 'cash_on_delivery',
      'Pagseguro' => 'pagseguro',
      'CajaVecina' => 'caja_vecina',
      'Baloto' => 'baloto',
      'Codensa' => 'codensa',
      'Efecty' => 'efecty',
      'Mercado Pago' => 'mercado_pago',
      'Pago contra entrega' => 'pago_contra_entrega',
      'Pago en tiendas 7eleven' => 'pago_en_tiendas_7eleven',
      'Pago en tiendas Oxxo' => 'pago_en_tiendas_oxxo',
      'Pagos Online' => 'pagos_online',
      'Place to Pay' => 'place_to_pay',
      'Redcompra' => 'redcompra',
      'Servipag' => 'servipag',
      'Skrill' => 'skrill',
      'Web Pay' => 'web_pay',
      'iDEAL' => 'idel',
      'Royal Mail' => 'royal_mail',
      'Collect+' => 'collect_plus',
      'Parcelforce' => 'parcelforce',
      'Ecourier' => 'ecourier',
      'Yodel' => 'yodel',
      'Leetchi' => 'leetchi',
      'Le Pot Commun' => 'le_pot_commun',
      'Apple Pay' => 'apple_pay',
      'Google Pay' => 'google_pay',
      'Invoice' => 'invoice'
    },
    popup_interval: {
      'never' => 'never',
      'daily' => 'daily',
      'weekly' => 'weekly',
      'monthly' => 'monthly'
    },
    font_family: {
      'Open Sans (default)' => '"Open Sans", sans-serif',
      'Museo' => 'Museo',
      'Museo Sans' => '"Museo Sans", sans-serif'
    },
    banner_themes: {
      'Xmas' => 'xmas',
      'Black Friday' => 'black-friday',
      'Cyber Monday' => 'cyber-monday',
      'Default' => 'default'
    },
    wls_footer_styles: {
      'default' => 'default',
      'first' => 'first',
      'second' => 'second',
      'third' => 'third',
      'fourth' => 'fourth'
    },
    flyout_style: {
      'default' => 'default',
      'first' => 'first'
    }
  }.with_indifferent_access

  after_commit :clear_templates_cache

  def self.custom_layout
    custom_layout = Rails.cache.fetch([Site.current.id, 'custom_layout']) do
      where(site_id: Site.current.id, name: 'custom_layout').first
    end
    custom_layout.present? ? custom_layout.value : nil
  end

  def self.footer_script
    footer_script = Rails.cache.fetch([Site.current.id, 'footer_script']) do
      where(site_id: Site.current.id, name: 'footer_script').first
    end
    footer_script.present? ? footer_script.value : nil
  end

  def self.body_script
    body_script = Rails.cache.fetch([Site.current.id, 'body_script']) do
      where(site_id: Site.current.id, name: 'body_script').first
    end
    body_script.present? ? body_script.value : nil
  end

  def self.mobile_custom_layout
    mobile_custom_layout = Rails.cache.fetch([Site.current.id, 'mobile_custom_layout']) do
      where(site_id: Site.current.id, name: 'mobile_custom_layout').first
    end
    mobile_custom_layout.present? ? mobile_custom_layout.value : nil
  end

  def self.head_script
    header_script = Rails.cache.fetch([Site.current.id, 'head_script']) do
      where(site_id: Site.current.id, name: 'head_script').first
    end
    header_script.present? ? header_script.value : nil
  end

  def self.clear_templates_cache
    if Site.current.present?
      Rails.cache.delete([Site.current.id, 'custom_layout'])
      Rails.cache.delete([Site.current.id, 'footer_script'])
      Rails.cache.delete([Site.current.id, 'body_script'])
      Rails.cache.delete([Site.current.id, 'head_script'])
      Rails.cache.delete([Site.current.id, 'mobile_custom_layout'])
    end
  end

  def clear_templates_cache
    self.class.clear_templates_cache
  end

  # Get the options for showing in html select input tag
  # @param  type [String] @see  above Constant OPTIONS
  # @param  show_empty_options [nil, Boolean] when true a "'Please select' => ''" is added to the top of the hash
  #
  # @return [HASH] returns the given option type declared in Option Constant
  def self.get_select_options(type, show_empty_options = nil)
    empty_hash = {'Please select' => ''}

    if show_empty_options
      empty_hash.merge(self::OPTIONS[type.to_sym])
    end

    self::OPTIONS[type.to_sym]
  end

end
