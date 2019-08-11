class CouponImport < ApplicationRecord
  include ActsAsImportable

  belongs_to :user
  validates_presence_of :user_id

  attr_accessor :origin_coupon_form, :coupon_id

  def run
    @urls = []
    uniq_sites = []
    error_messages = []

    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    coupons_to_save = []

    begin
      (2..spreadsheet.last_row).map do |i|
        coupon_new_hash = {}

        data_as_hash = Hash[[header, spreadsheet.row(i)].transpose]
        allowed_data = data_as_hash.to_hash.slice(*ImportedCoupon::allowed_import_params.map(&:to_s))

        # handle site_id received from file
        coupon_site_id = allowed_data['Site ID']
        coupon_site = Site.find(coupon_site_id)
        @site = SiteFacade.new(coupon_site)
        Site.current = coupon_site
        Time.zone = coupon_site.timezone

        uniq_sites << coupon_site
        uniq_sites.uniq!

        if allowed_data['Coupon ID'].present?
          coupon_id = allowed_data['Coupon ID'].to_i
          coupon = ImportedCoupon.find_or_initialize_by(id: coupon_id, site_id: coupon_site_id)
        else
          coupon = ImportedCoupon.new(site_id: coupon_site_id)
        end

        allowed_data.each_pair do |key, value|
          attribute = match_key_value(key, value, coupon, coupon_site)
          coupon_new_hash.merge!(attribute) if attribute.present?
        end

        coupon_new_hash.merge!(site_id: coupon_site_id, negative_votes: 0, positive_votes: 0, clicks: 0, origin_coupon_form: 1)
        coupon.attributes = coupon_new_hash

        if coupon.valid?
          coupons_to_save << coupon
        else
          coupon.errors.full_messages.each do |message|
            error_messages << "Row #{i}: #{message}"
          end
          next
        end
      end

      unless error_messages.present?
        transaction do
          raise ActiveRecord::Rollback unless coupons_to_save.each(&:save)
        end

        update_attribute(:status, 'done')
        update_priority_scores(uniq_sites)
        purge_related_sites(uniq_sites)
      end
    rescue StandardError => e
      error_messages << e.message
    end

    if error_messages.present?
      update_attributes(error_messages: error_messages, status: 'error')
    end
  end

  def match_key_value(key, value, coupon, coupon_site)
    case key.strip
    when 'Site ID'
      key = 'site_id'
      value = coupon.site_id # avoid overwriting site_id
    when 'Coupon ID'
      key = 'id'
    when 'Title'
      key = 'title'

      if value.present?
        value = value
      else
        value = coupon.title if coupon.title.present?
      end
    when 'Status'
      key = 'status'

      if value.present?
        value = value.downcase
      else
        value = coupon.new_record? ? 'active' : coupon.status
      end
    when 'URL'
      key = 'url'

      if value.present?
        value = sanitize_url(value)
      else
        value = coupon.url if coupon.url.present?
      end
    when 'Code'
      key = 'code'

      if value.present?
        value = value
      else
        value = coupon.code if coupon.code.present?
      end
    when 'Description'
      key = 'description'

      if value.present?
        value = value
      else
        value = coupon.description if coupon.description.present?
      end
    when 'Info Discount'
      key = 'info_discount'

      if value.present?
        value = value
      else
        value = coupon.info_discount if coupon.info_discount.present?
      end
    when 'Info Min Purchase'
      key = 'info_min_purchase'

      if value.present?
        value = value
      else
        value = coupon.info_min_purchase if coupon.info_min_purchase.present?
      end
    when 'Info Limited Clients'
      key = 'info_limited_clients'

      if value.present?
        value = value
      else
        value = coupon.info_limited_clients if coupon.info_limited_clients.present?
      end
    when 'Info Limited Brands'
      key = 'info_limited_brands'

      if value.present?
        value = value
      else
        value = coupon.info_limited_brands if coupon.info_limited_brands.present?
      end
    when 'Info Conditions'
      key = 'info_conditions'

      if value.present?
        value = value
      else
        value = coupon.info_conditions if coupon.info_conditions.present?
      end
    when 'Type'
      key = 'coupon_type'

      if value.present?
        value = value.downcase
      else
        value = coupon.coupon_type if coupon.coupon_type.present?
      end
    when 'Image URL'
      key = 'remote_logo_url'
      value = value.present? ? sanitize_https(value) : coupon.logo_url

      return if coupon.logo_url == value
    when 'Widget Header URL'
      key = 'remote_widget_header_image_url'
      value = value.present? ? sanitize_https(value) : coupon.widget_header_image_url

      return if coupon.widget_header_image == value
    when 'Logo Text First Line'
      key = 'logo_text_first_line'

      if value.present?
        value = value
      else
        value = coupon.logo_text_first_line if coupon.logo_text_first_line.present?
      end
    when 'Logo Text Second Line'
      key = 'logo_text_second_line'

      if value.present?
        value = value
      else
        value = coupon.logo_text_second_line if coupon.logo_text_second_line.present?
      end
    when 'Affiliate Network Slug'
      key = 'affiliate_network_id'

      if value.present?
        affiliate_network = AffiliateNetwork.active.find_by(slug: value)
        value = affiliate_network.present? ? affiliate_network.id : nil
      else
        value = coupon.affiliate_network_id if coupon.affiliate_network_id.present?
      end
    when 'Shop Slug'
      key = 'shop_id'

      if value.present?
        shop = Shop.find_by(slug: value, site: coupon_site) if value.present?
        coupon.shop = shop
        value = shop.id if shop.present?
      else
        value = coupon.shop_id if coupon.shop_id.present?
      end
    when 'Use Uniq Codes'
      key = 'use_uniq_codes'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.use_uniq_codes? ? coupon.use_uniq_codes : false
      end
    when 'Is Exclusive?'
      key = 'is_exclusive'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.is_exclusive? ? coupon.is_exclusive : false
      end
    when 'Is Editors Pick?'
      key = 'is_editors_pick'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.is_editors_pick? ? coupon.is_editors_pick : false
      end
    when 'Is Free?'
      key = 'is_free'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.is_free? ? coupon.is_free : false
      end
    when 'Is Hidden?'
      key = 'is_hidden'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.is_free? ? coupon.is_free : false
      end
    when 'Is Free Delivery?'
      key = 'is_free_delivery'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.is_free_delivery? ? coupon.is_free_delivery : false
      end
    when 'Is Mobile?'
      key = 'is_mobile'

      if value.present?
        value = true_or_false(value)
      else
        value = coupon.is_mobile? ? coupon.is_mobile : false
      end
    when 'Is Top?'
      key = 'is_top'

      if value.present?
        value = true_or_false(value)
      else
        value = (coupon.is_top?) ? coupon.is_top : false
      end
    when 'Savings'
      key = 'savings'

      if value.present?
        value = value
      else
        value = coupon.savings if coupon.savings.present?
      end
    when 'Savings In'
      key = 'savings_in'

      if value.present?
        value = value == '%' || value == 'percent' ? 'percent' : 'currency'
      else
        value = coupon.savings_in if coupon.savings_in.present?
      end
    when 'Currency'
      key = 'currency'

      if value.present?
        value = value
      else
        value = coupon.currency if coupon.currency.present?
      end
    when 'Shop List Priority'
      key = 'shop_list_priority'

      if value.present?
        value = value
      else
        value = coupon.shop_list_priority if coupon.shop_list_priority.present?
      end
    when 'Start Date'
      key = 'start_date'

      if value.present?
        value = DateTime.parse("#{value} 00:00:00").to_s(:db)
      else
        value = coupon.start_date if coupon.start_date.present?
      end
    when 'End Date'
      key = 'end_date'

      if value.present?
        value = DateTime.parse("#{value} 23:59:59").to_s(:db)
      else
        value = coupon.end_date if coupon.end_date.present?
      end
    when 'Category Slug'
      key = 'category_ids'
      if value.present?
        category_ids = []
        categories = value.tr(' ', '').split(',') if value.present?

        if categories.present?
          categories.each do |slug|
            category = Category.find_by(slug: slug, site: coupon_site)
            category_ids.push(category.id) if category.present?
          end
        end
        value = category_ids
      else
        value = coupon.category_ids if coupon.category_ids.present?
      end
    when 'Campaign Slug'
      key = 'campaign_ids'
      if value.present?
        campaign_ids = []
        campaigns = value.tr(' ', '').split(',') if value.present?

        if campaigns.present?
          campaigns.each do |slug|
            campaign = Campaign.find_by(slug: slug, site: coupon_site)
            campaign_ids.push(campaign.id) if campaign.present?
          end
        end
        value = campaign_ids
      else
        value = coupon.campaign_ids if coupon.campaign_ids.present?
      end
    end

    add_coupon_url_for_purging(coupon)

    { key => value }
  end

  def self.grid_filter(params)
    query = self
    query = query.where(user: User.current.allowed_active_users_of(self, true)) if User.current.present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(user: params[:user]) if params[:user].present?
    query = query.where('file like ?', "%#{params[:file]}%") if params[:file].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where('created_at >= ?', params['created_at_from']) if params['created_at_from'].present?
    query = query.where('created_at <= ?', params['created_at_to']) if params['created_at_to'].present?

    query
  end

  def self.grid_filter_dropdowns
    h = {}
    h[:user] = User.current.allowed_active_users_of(self, true).map do |user|
      { user.id => user.full_name }
    end
    h[:user].insert(0, {'' => 'all'})
    h
  end

  private

  def add_coupon_url_for_purging(coupon)
    @reloaded ||= false

    @urls << dynamic_url_for('shops', 'show', slug: coupon.shop.slug, host: hostname(coupon.site), only_path: false) if coupon.shop.present?
    coupon.categories.each do |cat|
      @urls << dynamic_url_for('categories', 'show', slug: cat.slug, parent_slug: cat.parent_slug, host: hostname(coupon.site), only_path: false)
    end

    coupon.campaigns.each do |campaign|
      if campaign.is_root_campaign? && !@reloaded
        DynamicRoutes.reload
        @reloaded = true
      end

      @urls << dynamic_campaign_url_for(campaign)
    end
  end

  def hostname(site)
    !Rails.env.development? ? site.hostname : 'cupon.es'
  end

  # this is a special method to deal with the weired imported chinese characters that come from
  # some excel sheets. Unless we have a better method we should use this to clear the urls
  def sanitize_url(url)
    url.gsub(/[^[:print:]]/, '').gsub('塹ᴻ䡿ⲯ嶂藄挧', '').tr(' ', '')
  end

  def true_or_false(value)
    if value == 'yes' || value.to_i.to_s == 1 # to_i.to_s is because it may arrive as float from excel
      true
    else
      false
    end
  end
end
