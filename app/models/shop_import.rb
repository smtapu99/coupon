class ShopImport < ApplicationRecord
  include ActsAsImportable

  belongs_to :user
  validates_presence_of :user_id

  def run
    uniq_sites = []
    error_messages = []

    begin
      ActiveRecord::Base.transaction do
        spreadsheet = open_spreadsheet
        header = spreadsheet.row(1)

        (2..spreadsheet.last_row).map do |i|
          data_as_hash = Hash[[header, spreadsheet.row(i)].transpose]
          shop_allowed_data = data_as_hash.to_hash.slice(*Shop::allowed_import_params.map(&:to_s))
          html_doc_allowed_data = data_as_hash.to_hash.slice(*HtmlDocument::allowed_import_params(user))

          shop_data = {}
          html_doc_data = {}

          # handle site_id received from file
          shop_site_id = shop_allowed_data['Site ID']
          shop_site = Site.find(shop_site_id)
          @site = SiteFacade.new(shop_site)
          Site.current = shop_site
          Time.zone = shop_site.timezone

          uniq_sites << shop_site
          uniq_sites.uniq!

          shop = load_shop_object(data_as_hash['Shop ID'], shop_allowed_data['Slug'], shop_site)

          @urls = [dynamic_url_for('shops', 'index', host: shop_site.hostname, only_path: false)]

          shop_allowed_data.each_pair do |key, value|
            attribute = match_key_value(key, value, shop)
            shop_data.merge!(attribute) if attribute.present?
          end
          shop_data.merge!(site_id: shop_site.id, is_imported: 1)

          html_doc_allowed_data.each_pair do |key, value|
            html_doc_data.merge!(match_html_document_key_value(key, value, shop.html_document))
          end

          shop.attributes = shop_data
          shop.html_document_attributes = html_doc_data

          unless shop.save
            shop.errors.full_messages.each do |message|
              error_messages << "Row #{i} (#{shop.slug}): #{message}"
            end
            next
          end
        end

        if error_messages.present?
          raise ActiveRecord::Rollback
        else
          update_attributes(status: 'done', error_messages: '')
          update_priority_scores(uniq_sites)
          purge_related_sites(uniq_sites)
        end
      end
    rescue StandardError => e
      error_messages << e.message
    end

    return unless error_messages.present?
    update_attributes(error_messages: error_messages, status: 'error')
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

  def load_shop_object(shop_id, slug, site)
    Shop.find(shop_id)
  rescue StandardError
    Shop.find_or_initialize_by(
      site: site,
      slug: slug
    )
  end

  def match_key_value(key, value, shop)
    case key
    when 'Site ID'
      key = 'site_id'
      value = shop.site_id # avoid overwriting the site_id
    when 'Global ID'
      key = 'global_id'
      value = value.present? ? value : shop.global_id
    when 'Status'
      key   = 'status'
      value = value.present? ? value.downcase : shop.status
    when 'Person In Charge'
      key   = 'person_in_charge_id'

      if value.present?
        # 'abc'.to_i => 0, '10'.to_i => 10 ... we use that to find out if the value is an email or an integer, and it works
        # even if "10" is uploaded as string
        user  = value.to_i.positive? ? User.find(value.to_i) : User.find_by(email: value) rescue nil
        value = user.present? ? user.id : nil
      else
        value = shop.person_in_charge_id if shop.person_in_charge_id.present?
      end
    when 'Prefered Affiliate Network Slug'
      key = 'prefered_affiliate_network_id'

      if value.present?
        affiliate_network = AffiliateNetwork.active.find_by(slug: value.downcase)
        value = affiliate_network.present? ? affiliate_network.id : nil
      else
        value = shop.prefered_affiliate_network_id if shop.prefered_affiliate_network_id.present?
      end
    when 'Shop Title'
      key   = 'title'
      value = value.present? ? value.to_s : shop.title
    when 'Tier Group'
      key   = 'tier_group'
      value = value.present? ? value.to_s : shop.tier_group
    when 'Anchor Text'
      key   = 'anchor_text'
      value = value.present? ? value.to_s : shop.anchor_text
    when 'Slug'
      key   = 'slug'
      value = value.present? ? value.to_s.downcase : shop.slug
    when 'Fallback URL'
      key   = 'fallback_url'
      value = value.present? ? value : shop.fallback_url
    when 'Link Title'
      key   = 'link_title'
      value = value.present? ? value : shop.link_title
    when 'Header Image'
      key   = 'remote_header_image_url'
      value = value.present? ? sanitize_https(value) : shop.header_image_url

      return if shop.header_image_url == value
    when 'First Coupon Image'
      key   = 'remote_first_coupon_image_url'
      value = value.present? ? sanitize_https(value) : shop.first_coupon_image_url

      return if shop.first_coupon_image_url == value
    when 'Logo'
      key   = 'remote_logo_url'
      value = value.present? ? sanitize_https(value) : shop.logo_url

      return if shop.logo_url == value
    when 'Logo Alt'
      key   = 'logo_alt_text'
      value = value.present? ? value : shop.logo_alt_text
    when 'Logo Title Text'
      key   = 'logo_title_text'
      value = value.present? ? value : shop.logo_title_text
    when 'Is Hidden'
      key = 'is_hidden'

      if value.present?
        value = (value == 'yes') ? 1 : 0
      else
        value = shop.is_hidden
      end
    when 'Is Top'
      key = 'is_top'

      if value.present?
        value = (value == 'yes') ? 1 : 0
      else
        value = shop.is_top
      end
    when 'Is Default Clickout'
      key = 'is_default_clickout'

      if value.present?
        value = (value == 'yes') ? 1 : 0
      else
        value = shop.is_default_clickout
      end
    when 'Is Direct Clickout'
      key = 'is_direct_clickout'

      if value.present?
        value = (value == 'yes') ? 1 : 0
      else
        value = shop.is_direct_clickout
      end
    when 'Is Featured'
      key = 'is_featured'

      if value.present?
        value = (value == 'yes') ? 1 : 0
      else
        value = shop.is_featured
      end
    when 'Clickout Value'
      key   = 'clickout_value'
      value = value.present? ? value.to_s.gsub(',', '.').to_f : shop.clickout_value # be sure that 1,0 becomes to 1.0
    when 'Category IDs'
      key   = 'shop_category_ids'
      value = value.present? ? value.to_s.gsub(' ', '').split(',') : shop.shop_category_ids
    when 'Address'
      key = 'info_address'
      value = value.present? ? value : shop.info_address
    when 'Phone'
      key = 'info_phone'
      value = value.present? ? value : shop.info_phone
    when 'Free Shipping'
      key = 'info_free_shipping'
      value = value.present? ? value : shop.info_free_shipping
    when 'Payment Methods'
      key = 'info_payment_methods'

      if value.present?
        value = value.split(',').map(&:strip)
      else
        value = shop.info_payment_methods
      end
    when 'Delivery Methods'
      key = 'info_delivery_methods'

      if value.present?
        value = value.split(',').map(&:strip)
      else
        value = shop.info_delivery_methods
      end
    end

    add_shop_url_for_purging(shop)
    { key => value }
  end

  def match_html_document_key_value(key, value, html_document)
    case key
    when 'Heading 1'
      key = 'h1'

      if value.present?
        value
      else
        if html_document.present? && html_document.h1.present?
          value = html_document.h1
        end
      end
    when 'Heading 2'
      key = 'h2'

      if value.present?
        value
      else
        if html_document.present? && html_document.h2.present?
          value = html_document.h2
        end
      end
    when 'Meta Robots'
      key = 'meta_robots'

      if value.present?
        value
      else
        if html_document.present? && html_document.meta_robots.present?
          value = html_document.meta_robots
        end
      end
    when 'Meta Keywords'
      key = 'meta_keywords'

      if value.present?
        value
      else
        if html_document.present? && html_document.meta_keywords.present?
          value = html_document.meta_keywords
        end
      end
    when 'Meta Description'
      key = 'meta_description'

      if value.present?
        value
      else
        if html_document.present? && html_document.meta_description.present?
          value = html_document.meta_description
        end
      end
    when 'Meta Title'
      key = 'meta_title'

      if value.present?
        value
      else
        if html_document.present? && html_document.meta_title.present?
          value = html_document.meta_title
        end
      end
    when 'Meta Title Fallback'
      key = 'meta_title_fallback'

      if value.present?
        value
      else
        if html_document.present? && html_document.meta_title_fallback.present?
          value = html_document.meta_title_fallback
        end
      end
    when 'Content'
      key = 'content'

      if value.present?
        value
      else
        if html_document.present? && html_document.content.present?
          value = html_document.content
        end
      end
    when 'Welcome Text'
      key = 'welcome_text'

      if value.present?
        value
      else
        if html_document.present? && html_document.welcome_text.present?
          value = html_document.welcome_text
        end
      end
    when 'Head Scripts'
      key = 'head_scripts'

      if value.present?
        value
      else
        if html_document.present? && html_document.head_scripts.present?
          value = html_document.head_scripts
        end
      end
    when 'Header Image'
      return {}
    end

    { key => value }
  end

  def add_shop_url_for_purging(shop)
    site = shop.site
    @urls << dynamic_url_for('shops', 'show', slug: shop.slug, host: site.hostname , only_path: false)
  end
end
