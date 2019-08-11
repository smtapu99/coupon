class Setting < Option
  include ActAsEdgeCachable
  include ActsAsSiteable
  include ActsAsCustomCssGenerator
  include ActsAsRoutesReloader

  attr_accessor :routes_changed
  serialize :value, OpenStruct

  # scopes
  scope :for_campaign, ->(campaign_id) { where(name: 'setting', site_id: Site.current.blank? ? nil : Site.current.id, campaign_id: campaign_id) }

  # callbacks
  before_save :add_name

  validate :mail_form_email_adresses, if: -> { self.class.mail_forms_changed }
  validate :custom_styles_allowed?
  validate :route_settings, if: -> { self.class.routes_changed }
  validate :secondary_summary_widget_allowed

  default_scope { where(name: 'setting') }

  def self.serialized_attr_accessor(args)
    args.each do |method_name|
      eval "
        cattr_accessor :#{method_name}_changed

        def #{method_name}
          (self.value || {}).#{method_name}
        end

        def #{method_name}=(value)
          self.value ||= {}
          self.value.#{method_name} = value.to_ostruct_recursive
        end

        def self.current_#{method_name}
          setting = self.where(site_id: Site.current.id).first
            if setting.present? && setting.#{method_name}.present?
              setting.#{method_name}
            else
              nil
            end
        end
      "
    end
  end

  SERIALIZABLE_ATTRIBUTES = [
    :style,
    :alert,
    :publisher_site,
    :experimental,
    :admin_rules,
    :newsletter,
    :image_upload,
    :legal_pages,
    :default_status,
    :routes,
    :caching,
    :mail_forms,
    :homepage,
    :tracking,
    :visibility,
    :widget_ranking,
    :banner,
    :shop_banner,
    :menu
  ]

  serialized_attr_accessor(SERIALIZABLE_ATTRIBUTES)

  def self.reset_changed_flags
    self::SERIALIZABLE_ATTRIBUTES.each do |method_name|
      send("#{method_name}_changed=", false)
    end
  end

  # inits the setting model
  # in case you visit a campaign make sure that campaign.current is set before you call this method
  # returns setting
  def self.init_setting(site)
    # reset the setting in any case
    RequestStore.store[:setting_current] = nil
    setting = Setting.where(site_id: site.id, campaign_id: nil).first

    if Campaign.current.present?
      campaign_settings   = Setting.where(name: 'setting', site_id: site.id, campaign_id: Campaign.current.id).first

      campaign_value      = campaign_settings.present? ? campaign_settings.value : OpenStruct.new
      campaign_value_hash = campaign_value.marshal_dump_recursive
      default_value_hash  = setting.present? ? setting.value.marshal_dump_recursive : Hash.new
      setting_values      = default_value_hash.deep_merge(campaign_value_hash)

      # assign the merged hash as value to a new setting instance
      setting       = setting.dup
      setting.value = setting_values.to_ostruct_recursive
    end

    # make sure class variables dont get shared across requests
    RequestStore.store[:setting_current] = setting
  end

  def self.get(key, opts = {})
    return opts[:default] unless Site.current.present?

    current_setting = if Rails.env.test? || RequestStore.store[:setting_current].blank?
      init_setting(Site.current)
    else
      RequestStore.store[:setting_current]
    end

    if current_setting.present? and result = current_setting.get(key, opts) and !result.nil?
      return result
    else
      return opts[:default]
    end
  end

  def get(key, opts = {})
    raise 'Invalid 2nd param, expect opts to be a hash; e.g. {default: "default value"}' unless opts.is_a?(Hash)
    keys = key.split('.')
    if sett = self.try(keys[0])
      return sett if keys.size == 1
      (sett.send(keys[1]) != nil && sett.send(keys[1]) != '') ? sett.send(keys[1]) : opts[:default]
    else
      opts[:default]
    end
  end

  def stylesheet_filename(theme)
    "#{site.host_to_file_name}-#{style.last_compiled_at}.css"
  end

  def image_url(name)
    raise 'Setting.image_url is deprecated! use ImageSetting.{image_type}_url intead'
  end

  # Returns allowed import parameter
  #
  # @return [Array] allowed import parameter
  def self.publisher_site_allowed_import_params
    [
      'Show Footer', 'Show Header Logo Area', 'Show Main Navigation', 'Custom Head Scripts',
      'Show Search Bar', 'Show Coupon List Filter'
    ]
  end

  def self.remove_field(setting_id, field, save_it = true)
    setting = Setting.find(setting_id)
    return unless setting

    setting.remove_field field, save_it
  end

  def remove_field(field, save_it = true)
    if field.starts_with?('style')
      field.gsub!('.', '_')
      field.gsub!('style_','')
      if style.present? && !style.send(field).nil?
        style.delete_field(field)
        save if save_it
      end
    elsif field.starts_with?('image_upload')
      field.gsub!('.', '_')
      field.gsub!('image_upload_','')
      if image_upload.present? && !image_upload.send(field).nil?
        image_upload.delete_field(field)
        save if save_it
      end
    end
  end

  def home_breadcrumb_name_needed?
    return false if self.try(:routes).try(:application_root_dir).to_s.gsub('/', '').blank?
    return false if self.try(:publisher_site).try(:home_breadcrumb_name).present?
    true
  end

  private

  def custom_styles_allowed?
    errors.add(:custom_styles, 'cannot be enabled when theme is webpacked') if style.try(:theme).to_s.include?('webpacked') && style.try(:styles_enabled).to_s == '1'
  end

  def secondary_summary_widget_allowed
    unallowed_pair = ["best_deals_summary_advanced", "best_deals_summary_advanced_code"]

    return unless publisher_site&.secondary_summary_widget.present?

    if publisher_site.secondary_summary_widget == publisher_site.summary_widget
      errors.add(:secondary_summary_widget, 'cannot be the same as "Summary Widget"')
    elsif unallowed_pair.include?(publisher_site.secondary_summary_widget) && unallowed_pair.include?(publisher_site.summary_widget)
      errors.add(:base, 'Unallowed to use "Best Deals Summary Advanced" and "Best Deals Summary Advanced Code" widgets together. Please select another widgets')
    end
  end

  def route_settings
    errors.add(:application_root_dir, 'cannot be /') if routes.try(:application_root_dir) == '/'
    errors.add(:campaign_page, 'cannot start with /deals; /deals is a reserved path') if routes.try(:campaign_page).to_s.start_with?('/deals')
    errors.add(:campaign_page, 'should not be at root like /:slug. ') if routes.try(:campaign_page) == '/:slug'
    errors.add(:campaign_sub_page, 'should not be at root like /:parent_slug/:slug.') if routes.try(:campaign_sub_page) == '/:parent_slug/:slug'

    if routes.try(:shop_campaign_page).present? && routes.try(:shop_show).present?
      search = routes.shop_show.gsub(':slug', ':shop_slug')
      errors.add(:shop_campaign_page, 'does not contain Shop Page url. Pls keep the same structure') unless routes.shop_campaign_page.include?(search)
    end

    if routes.try(:campaign_sub_page).present? && routes.try(:campaign_page).present?
      search = routes.campaign_page.gsub(':slug', ':parent_slug')
      errors.add(:campaign_sub_page, 'does not contain Campaign Page url. Pls keep the same structure') unless routes.campaign_sub_page.include?(search)
    end
  end

  def mail_form_email_adresses
    emails = mail_forms.present? ? mail_forms.contact_emails : nil

    if emails.blank?
      errors.add(:email, 'is mandatory')
    elsif emails.include?(',')
      emails.split(',').each do |email|
        errors.add(:email, 'is not a proper email') unless email.strip.match(/.+@.+\..+/i)
      end
    end
  end

  def add_name
    self.name = 'setting'
  end
end
