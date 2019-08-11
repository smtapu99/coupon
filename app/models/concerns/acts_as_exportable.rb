module ActsAsExportable
  extend ActiveSupport::Concern

  CSV_EXPORT_COLUMN_HEADERS = {
    coupon: {
      'id' => 'Coupon ID',
      'site_id' => 'Site ID',
      'title' => 'Title',
      'status' => 'Status',
      'coupon_type' => 'Type',
      'shop_slug' => 'Shop Slug',
      'url' => 'URL',
      'code' => 'Code',
      'description' => 'Description',
      'info_discount' => 'Info Discount',
      'info_min_purchase' => 'Info Min Purchase',
      'info_limited_clients' => 'Info Limited Clients',
      'info_limited_brands' => 'Info Limited Brands',
      'info_conditions' => 'Info Conditions',
      'start_date' => 'Start Date',
      'end_date' => 'End Date',
      'use_uniq_codes' => 'Use Uniq Codes',
      'is_top' => 'Is Top?',
      'is_exclusive' => 'Is Exclusive?',
      'is_editors_pick' => 'Is Editors Pick?',
      'is_free' => 'Is Free?',
      'is_hidden' => 'Is Hidden?',
      'is_free_delivery' => 'Is Free Delivery?',
      'savings' => 'Savings',
      'savings_in' => 'Savings In',
      'currency' => 'Currency',
      'joined_category_slugs' => 'Category Slug',
      'joined_campaign_slugs' => 'Campaign Slug',
      'is_mobile' => 'Is Mobile?',
      'logo_url' => 'Image URL',
      'widget_header_image_url' => 'Widget Header URL',
      'logo_text_first_line' => 'Logo Text First Line',
      'logo_text_second_line' => 'Logo Text Second Line',
      'affiliate_network_slug' => 'Affiliate Network Slug',
      'shop_list_priority' => 'Shop List Priority',
    },
    coupon_code: {
      'id' => 'coupon_code_id',
      'site_id' => 'site_id',
      'coupon_id' => 'coupon_id',
      'code' => 'code',
      'tracking_user_id' => 'tracking_user_id',
      'is_imported' => 'is_imported',
      'end_date' => 'end_date',
      'used_at' => 'used_at',
      'created_at' => 'created_at',
      'updated_at' => 'updated_at',
    },
    shop: {
      'id' => 'Shop ID',
      'site_id' => 'Site ID',
      'global_id' => 'Global ID',
      'tier_group' => 'Tier Group',
      'status' => 'Status',
      'title' => 'Shop Title',
      'anchor_text' => 'Anchor Text',
      'slug' => 'Slug',
      'html_document_h1' => 'Heading 1',
      'html_document_h2' => 'Heading 2',
      'html_document_meta_robots' => 'Meta Robots',
      'html_document_meta_keywords' => 'Meta Keywords',
      'html_document_meta_description' => 'Meta Description',
      'html_document_meta_title' => 'Meta Title',
      'html_document_meta_title_fallback' => 'Meta Title Fallback',
      'html_document_content' => 'Content',
      'html_document_welcome_text' => 'Welcome Text',
      'html_document_head_scripts' => 'Head Scripts',
      'fallback_url' => 'Fallback URL',
      'link_title' => 'Link Title',
      'header_image_url' => 'Header Image',
      'first_coupon_image' => 'First Coupon Image',
      'logo_url' => 'Logo',
      'logo_alt_text' => 'Logo Alt',
      'logo_title_text' => 'Logo Title Text',
      'is_hidden' => 'Is Hidden',
      'is_top' => 'Is Top',
      'is_default_clickout' => 'Is Default Clickout',
      'is_direct_clickout' => 'Is Direct Clickout',
      'person_in_charge_id' => 'Person In Charge',
      'prefered_affiliate_network_slug' => 'Prefered Affiliate Network Slug',
      'shop_category_ids' => 'Category IDs',
      'clickout_value' => 'Clickout Value',
      'info_address' => 'Address',
      'info_phone' => 'Phone',
      'info_free_shipping' => 'Free Shipping',
      'info_payment_methods' => 'Payment Methods',
      'info_delivery_methods' => 'Delivery Methods'
    },
    campaign: {
      'id' => 'Campaign ID',
      'site_id' => 'Site ID',
      'parent_id' => 'Parent ID',
      'coupon_filter_text' => 'Coupon Filter Headline',
      'priority_coupon_ids' => 'Priority Coupon IDs',
      'start_date' => 'Start Date',
      'end_date' => 'End Date',
      'h1_first_line' => 'H1 First Line',
      'h1_second_line' => 'H1 Second Line',
      'html_document_h2' => 'H2',
      'name' => 'Name',
      'nav_title' => 'Nav Title',
      'shop_id' => 'Shop',
      'slug' => 'Slug',
      'status' => 'Status',
      'is_root_campaign' => 'Is Root Campaign',
      'template' => 'Template',
      'related_shop_ids' => 'Related Shop IDs',
      'html_document_header_image' => 'Header Image',
      'html_document_content' => 'Content',
      'html_document_meta_robots' => 'Meta Robots',
      'html_document_meta_keywords' => 'Meta Keywords',
      'html_document_meta_description' => 'Meta Description',
      'html_document_meta_title' => 'Meta Title',
      'html_document_welcome_text' => 'Welcome Text',
      'sem_logo_url' => 'SEM Page Logo URL',
      'sem_background_url' => 'SEM Page Background URL',

      'setting_site_show_footer' => 'Show Footer',
      'setting_site_custom_head_scripts' => 'Custom Head Scripts',
    },
    global: {
      'id' => 'Global ID',
      'name' => 'Name'
    },
    tag: {
      'id' => 'Tag ID',
      'word' => 'Word',
      'category_slug' => 'Category Slug',
      'is_blacklisted' => 'Is Blacklisted'
    }
  }

  included do

    attr_accessor :created_at_from, :created_at_to

    def self.flatten_date_array name, hash, type = 'date'
      if type == 'date'
        a = %w(1 2 3).map { |e| hash["#{name}(#{e}i)"].to_i }
      elsif type == 'datetime'
        a = %w(1 2 3 4 5).map { |e| hash["#{name}(#{e}i)"].to_i  }
        a << '00' if name.end_with?('_from')
        a << '59' if name.end_with?('_to')
        a
      else
        raise 'Invalid date type'
      end
    end

    def self.concat_date name, hash
      t = Time.zone.local(*flatten_date_array(name, hash, 'date'))
      t.utc
    end

    def self.concat_datetime name, hash, type = 'date'
      t = Time.zone.local(*flatten_date_array(name, hash, 'datetime'))
      t.utc.to_s(:db)
    end

    def class_column_names
      self.class.name.constantize.column_names
    end

    def export_column_value key
      value = self.send(key)
      case key.to_s
      when 'is_top',
        'is_exclusive',
        'is_editors_pick',
        'is_free',
        'is_hidden',
        'is_free_delivery',
        'is_mobile',
        'is_imported',
        'is_hidden',
        'is_top',
        'is_default_clickout',
        'is_direct_clickout',
        'is_root_campaign',
        'is_blacklisted',
        'use_uniq_codes'
        ActiveRecord::Type::Boolean.new.cast(value) ? 'yes' : 'no'
      when 'shop_category_ids', 'related_shop_ids'
        value.join(',')
      when 'info_payment_methods', 'info_delivery_methods'
        value.reject(&:blank?).join(',')
      when 'created_at', 'updated_at', 'start_date', 'end_date'
        value.to_date.strftime('%Y-%m-%d') if value.present?
      when 'html_document_header_image'
        value = value.url
      else
        value
      end
    end

    def csv_mapped_attributes
      attrs = []
      CSV_EXPORT_COLUMN_HEADERS[self.class.name.underscore.downcase.to_sym].each do |k, v|
        attrs << export_column_value(k)
      end
      attrs
    end
  end
end
