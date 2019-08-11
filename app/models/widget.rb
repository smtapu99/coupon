class Widget < WidgetBase
  before_save :set_widget_defaults
  validates_format_of :href, :with => URI::regexp(%w(http https)), if: -> { self.widget? && self.href.present? }

  default_scope { where(widget_type: 'widget') }

  before_destroy :delete_from_widget_area

  serialized_attr_accessor :title,
    :discount_bubbles,
    :hot_offers,
    :subpage_teaser,
    :premium_hero,
    :premium_widget,
    :width,
    :premium_offer_rows,
    :top_sales,
    :header_color,
    :header_icon,
    :css_class,
    :columns,
    :without_box,
    :show_in_categories,
    :show_in_shops,
    :without_header,
    :transparent_widget,
    :columns,
    :categories,
    :tag,
    :href,
    :alt,
    :coupons,
    :image,
    :image_url,
    :remove_image,
    :redirection_url,
    :coupon_ids,
    :categories,
    :shops,
    :tags,
    :limit,
    :content,
    :order_by,
    :order_direction,
    :custom_style,
    :delay,
    :animate,
    :amount,
    :tag_line,
    :gap_filler,
    :attach_newsletter_popup,
    :is_external_url,
    :tracking_name,
    :popup_start_date,
    :popup_end_date,
    :popup_interval,
    :subtitle,
    :background_url,
    :background,
    :mobile_background_url,
    :logo_url,
    :contact_emails,
    :name_placeholder,
    :email_placeholder,
    :extra_field_placeholder,
    :clickout_url,
    :success_modal_text,
    :newsletter_signup,
    :newsletter_mailchimp_list,
    :ad_code,
    :images,
    :category,
    :teaser_positions,
    :placeholder,
    :button_text,
    :featured_coupons_type,
    :shop_list_shops,
    :shop_list_columns,
    :background_color,
    :countdown_date,
    :show_countdown,
    :teaser_links,
    :shop,
    :section_one_header,
    :section_two_header,
    :rss_feed_url,
    :post_count,
    :text,
    :rotated_coupon_ids

  def self.remove_field_from_widget(widget_name, field)
    Widget.where(name: widget_name).each do |widget|
      unless widget.value.send(field).nil?
        widget.value.delete_field(field)
        widget.save
      end
    end
  end

  def defaults
    defaults = {}
    case name
    when 'newsletter'
      defaults[:button_color] = '.NEWSLETTER_BUTTONCOLOR'
      defaults[:button_text] = 'Submit'
      defaults[:columns] = 1
      defaults[:header_icon] = 'envelope'
    when 'featured_coupons'
      defaults[:columns] = 3
    when 'featured_images'
      defaults[:columns] = 3
    when 'subpage_teaser'
      defaults[:columns] = 3
    when 'premium_hero'
      defaults[:columns] = 3
    when 'premium_offers'
      defaults[:columns] = 3
    when 'countdown_header'
      defaults[:columns] = 3
    when 'quicklinks'
      defaults[:columns] = 3
    when 'newsletter'
      defaults[:columns] = 3
    when 'text'
      defaults[:columns] = 3
      defaults[:content] = ''
      defaults[:css_class] = ''
      defaults[:header_icon] = 'bubble'
      defaults[:title] = '.TEXT_TITLE'
    when 'top_x_coupons'
      defaults[:columns] = 1
      defaults[:title] = 'TOP_X_COUPONS_WIDGET_TITLE'
    end
    defaults
  end

  private

  def delete_from_widget_area
    WidgetArea.by_site_and_campaign(self.site, self.campaign).reload.each do |area|
      next unless area.widget_order
      area.widget_order.delete(self.id.to_s)
      area.save
    end
  end

  def set_widget_defaults
    self.site_id = Site.current.id if Site.current
    self.widget_type = 'widget'
    self.value = OpenStruct.new(self.value)
  end
end
