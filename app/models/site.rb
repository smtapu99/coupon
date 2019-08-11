class Site < ApplicationRecord
  include ActsAsCurrentEntity
  include ActsAsBlankNilifier
  include ActsAsRoutesReloader
  include ActsAsStatusable
  has_statuses(
   active: 'active',
   inactive: 'inactive'
  )

  attr_accessor :relevant_categories, :visible_coupons, :create_like_site_id

  mount_uploader :favicon, Admin::BaseUploader

  # relations
  has_many :affiliate_networks
  has_many :alerts
  has_many :options
  has_many :redirections
  has_many :tracking_clicks
  has_many :tracking_users
  has_many :campaigns
  has_many :root_campaigns, -> { where(is_root_campaign: true) }, class_name: 'Campaign'
  has_many :static_pages
  has_many :external_urls
  has_many :coupon_codes
  has_many :campaign_imports
  has_many :shop_imports
  has_many :newsletter_subscribers
  has_many :site_custom_translations

  belongs_to :country

  has_many :banners
  has_many :site_users
  has_many :country_users, through: :country
  has_many :users, through: :site_users
  has_many :snippets
  has_many :tags, through: :country, source: :tags
  has_many :shops
  has_many :coupons
  has_many :categories
  has_many :main_categories, -> { where main_category: true }, class_name: 'Category'

  has_many :widget_areas
  has_many :widgets

  has_one :setting, -> {where 'options.campaign_id is null and name ="setting"' }
  has_one :api_key
  has_one :image_setting

  has_many :site_coupon_clicks

  # validations
  validates_presence_of :name
  validates_presence_of :hostname
  validates_uniqueness_of :hostname, unless: -> { is_multisite? }
  validates_presence_of :country

  # callbacks
  before_save :remove_protocol_from_url
  before_save :nilify_blanks
  before_save :block_shops_and_coupons, if: -> { status_changed? && status == 'inactive' }
  after_create :prepare_site
  after_create :create_image_setting
  after_create :ensure_api_token

  scope :active, -> { where status: 'active' }

  # # used for migration with zero downtime.
  # # disables writes to the rejected colums
  def self.columns
    super.reject do |column|
      [
        'favicon',
        'use_https'
      ].include?(column.name.to_s)
    end
  end

  def protocol
    Frontend::Application.config.force_ssl ? 'https' : 'http'
  end

  def favicon_asset_path(path)
    asset_hostname_for_fog + '/favicons/' + id.to_s + '/' + path
  end

  def is_multisite?
    is_multisite
  end

  def host_and_subdir_name
    return hostname unless is_multisite?
    "#{hostname}/#{subdir_name.sub('/', '')}"
  end

  def all_users
    (users + country_users).uniq
  end

  def active_shops
    shops.active
  end

  def self.site_currency(locale = nil)
    locale ||= I18n.locale

    case locale.to_sym
    when :'es-ES', :'it-IT', :'fr-FR', :'de-DE'
      '€'
    when :'ru-RU'
      'руб.'
    when :'pl-PL'
      'zł'
    when :'pt-BR'
      'R$'
    when :'en-GB'
      '£'
    else
      '$'
    end
  end

  def self.multisite_per_request(request)
    path = URI.parse(request.original_url).path rescue nil
    return if path.nil?

    first_dir = path.split('/').reject(&:empty?).first
    where(hostname: request.host, is_multisite: true, subdir_name: "/#{first_dir}").first if first_dir.present?
  end

  def self.get_current_user_sites
    where(id: SiteCountry::get_current_user_sites_id).all
  end

  def self.by_host(host)
    where(hostname: host).limit(1)
  end

  def self.grid_filter(params)
    query = self
    query = query.where(id: User.current.allowed_site_ids)
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query = query.where('hostname like ?', "%#{params[:hostname]}%") if params[:hostname].present?
    query = query.where('time_zone like ?', "%#{params[:time_zone]}%") if params[:time_zone].present?
    query = query.joins(:country).where('countries.name like ?', "%#{params[:country]}%" ) if params[:country].present?
    query
  end

  #
  # returns the default routes merged with the defined routes from settings
  #
  # @return [Hash] Hash of routes
  def routes
    if setting &. routes.present?
      default_routes.merge(
        setting.routes.marshal_dump.delete_if { |k, v| v.blank? }
      )
    else
      default_routes
    end
  end

  def default_routes
    # take care about the order here .. first serves first
    {
      contact_form: '/contact',
      report_form: '/report',
      partner_form: '/partner',
      shop_index: '/shops',
      category: '/categories',
      popular_coupons: '/popular-coupons',
      top_coupons: '/top-coupons',
      new_coupons: '/new-coupons',
      expiring_coupons: '/expiring-coupons',
      free_delivery_coupons: '/free-delivery-coupons',
      free_coupons: '/free-coupons',
      exclusive_coupons: '/exclusive-coupons',
      search_page: '/search',
      go_to_coupon: '/go-to-coupon/:id',
      category_show: '/category/:slug',
      subcategory_show: '/category/:parent_slug/:slug',
      campaign_sub_page: '/campaign/:parent_slug/:slug',
      campaign_page: '/campaign/:slug',
      shop_show: '/shop/:slug',
      shop_campaign_page: '/shop/:shop_slug/:slug',
      page_show: '/:slug.html',
    }
  end

  def self.cached_find_by_host(host)
    Rails.cache.fetch([name, host]) do
      where(host: host)
    end
  end

  def self.host_to_file_name
    current.hostname.sub(/^www/, '').tr('.', '')
  end

  def hostname_with_protocol
    "#{protocol}://#{hostname}"
  end

  def id_and_name
    "#{id.to_s} - #{name}"
  end

  def host_to_file_name
    hostname.sub(/^www/, '').tr('.', '')
  end

  def only_domain
    hostname.sub(/^www\./, '')
  end

  def style_settings_enabled?
    Setting::get('style.styles_enabled', default: 0).to_i == 1
  end

  # Gets the clicks count for all coupons related to the current site
  #
  # @return [Integer] Default: 0
  def coupon_clicks
    site_coupon_clicks.sum(:clicks)
  end

  def asset_hostname_for_fog
    @asset_hostname_for_fog ||= 'https://' + CarrierWave::Uploader::Base.fog_directory
  end

  def self.current_shops
    Rails.cache.fetch([current.id, 'current_shops']) do
      current.shops
    end
  end

  def surrogate_key
    hostname.gsub(/[^0-9A-Za-z]/, '')
  end

  def timezone
    time_zone.present? ? time_zone : 'Berlin'
  end

  private

  def prepare_site
    return true unless create_like_site_id.present?

    PrepareSiteService.call(self, Site.find(create_like_site_id), true)
  end

  # Removes the protocol from the url field
  #
  # @return [string] site.com
  def remove_protocol_from_url
    hostname.sub!(/^https?:\/\//, '')
    hostname.delete('/')
  end

  def create_image_setting
    ImageSetting.find_or_create_by(site_id: id)
  end

  def ensure_api_token
    ApiKey.find_or_create_by(site_id: id)
  end

  def block_shops_and_coupons
    Site::UpdateStatus::Block.call self
  end
end
