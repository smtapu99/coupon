class HtmlDocument < ApplicationRecord
  include ApplicationHelper, ActsAsFilterable

  belongs_to :htmlable, polymorphic: true

  mount_uploader :header_image, Admin::HtmlDocumentUploader if (ENV['RAKE_IMPORT'].nil?)
  mount_uploader :mobile_header_image, Admin::HtmlDocumentUploader if (ENV['RAKE_IMPORT'].nil?)

  scope :with_htmlable_id, -> (id) { where(htmlable_id: id) }
  scope :with_htmlable_type, -> (type) { where(htmlable_type: type) }

  # Returns allowed import parameter
  #
  # @return [Array] allowed import parameter
  def self.allowed_import_params(user=nil)
    params = [
      'Heading 1',
      'Heading 2',
      'Meta Robots',
      'Meta Keywords',
      'Meta Description',
      'Meta Title',
      'Content',
      'Welcome Text',
      'Head Scripts',
      'Meta Title Fallback',
      'Header Image',
      'Mobile Header Image',
      'Header Font Color',
      'H2'
    ]

    if user.present? && !user.can_metas?
      return params - forbidden_metas
    end

    params
  end

  def self.forbidden_metas
    [
      'Heading 1',
      'Heading 2',
      'Meta Robots',
      'Meta Keywords',
      'Meta Description',
      'Meta Title',
      'Meta Title Fallback',
      'H2'
    ]
  end

  def dynamic_h1(coupons = nil)
    @dynamic_h1 ||= resolve_dynamic(:h1, coupons)
  end

  def dynamic_h2(coupons = nil)
    @dynamic_h2 ||= resolve_dynamic(:h2, coupons)
  end

  def dynamic_meta_title(coupons = nil)
    return '' if meta_title.blank?

    if fallback_title_required?(coupons)
      return replace_meta_vars(meta_title_fallback, coupons)
    end

    replace_meta_vars(meta_title, coupons)
  end

  def dynamic_meta_description(coupons = nil)
    @meta_description ||= resolve_dynamic(:meta_description, coupons)
  end

  def darken_header_image?
    header_image_dark_filter
  end

  def is_shop_or_category?
    htmlable_type == "Shop" || htmlable_type == "Category"
  end

  private

  def fallback_title_required?(coupons)
    meta_title_fallback.present? && \
    (
      (meta_title.include?('<savings_percentage>') && savings_percentage(coupons).to_i.zero?) || \
      (meta_title.include?('<top_position_savings>') && top_position_savings_string(coupons).blank?) || \
      (meta_title.include?('<top_exclusive_value>') && top_position_savings_string(coupons, false).blank?) || \
      (includes_coupon_info_discount?(meta_title) && top_3_coupons_discount_hash(coupons).blank?)
    )
  end

  def includes_coupon_info_discount?(string)
    included = false
    (1..3).map { |number| "<coupon#{number}_info_discount>" }.each do |variable|
      included ||= string.include?(variable)
    end
    included
  end

  def resolve_dynamic(attribute, coupons = nil)
    orig = read_attribute(attribute)
    replace_meta_vars(orig, coupons) if orig.present?
  end

  def savings_percentage(coupons)
    return '' unless coupons.present?
    @savings_percentage ||= coupons.savings_percentage.to_s
  end

  def active_coupons_count(coupons)
    return '' unless coupons.present?
    @active_coupons_count ||= coupons.size
  end

  def top_position_savings_string(coupons, only_exclusive=false)
    return '' unless coupons.present?
    @top_position_savings_string ||= coupons.top_position_savings_string(only_exclusive).to_s
  end

  def top_3_coupons_discount_hash(coupons)
    top_3_coupons = coupons&.take(3)
    return '' if top_3_coupons.blank?

    coupon_discounts = ActiveSupport::HashWithIndifferentAccess.new
    3.times.each_with_index do |_, i|
      coupon_discounts["<coupon#{i+1}_info_discount>"] = top_3_coupons[i]&.info_discount
    end
    coupon_discounts
  end

  def replace_meta_vars(string, coupons = nil)
    if string.include?('<year>')
      string = string.gsub('<year>', Time.now.year.to_s)
    end

    if string.include?('<month>')
      @month_number_to_word ||= month_number_to_word(Time.now.month.to_s)
      string = string.gsub('<month>', @month_number_to_word)
    end

    if string.include?('<month_abbrv>')
      current_scope = I18n.global_scope
      I18n.global_scope = :backend
      @month_number_to_abbr = (I18n.t :abbr_month_names, :scope => :date)[Time.now.month]
      I18n.global_scope = current_scope
      string = string.gsub('<month_abbrv>', @month_number_to_abbr.titleize)
    end

    if string.include?('<savings_percentage>')
      string = string.gsub('<savings_percentage>', savings_percentage(coupons) + '%') if savings_percentage(coupons).present?
    end

    if string.include?('<active_coupons_count>')
      string = string.gsub('<active_coupons_count>', active_coupons_count(coupons).to_s)
    end

    if string.include?('<top_position_savings>')
      string = string.gsub('<top_position_savings>', top_position_savings_string(coupons))
    end

    if string.include?('<top_exclusive_value>')
      string = string.gsub('<top_exclusive_value>', top_position_savings_string(coupons, true))
    end

    if string.include?('<category_name>')
      string = string.gsub('<category_name>', htmlable.name) if htmlable.is_a?(Category)
      string = string.gsub('<category_name>', '')
    end

    if string.include?('<shop_name>')
      string = string.gsub('<shop_name>', htmlable.title) if htmlable.is_a?(Shop)
      string = string.gsub('<shop_name>', '')
    end

    if string.include?('<campaign_name>')
      string = string.gsub('<campaign_name>', htmlable.name) if htmlable.is_a?(Campaign)
      string = string.gsub('<campaign_name>', '')
    end

    if string.include?('<title_of_top_coupon>')
      coupon = coupons.first
      string = string.gsub('<title_of_top_coupon>', coupon.title) if coupon
      string = string.gsub('<title_of_top_coupon>', '')
    end

    if string.include?('<exclusive>')
      replace_exclusive = coupons.where(is_exclusive: 1).empty? ? '' : I18n.t(:exclusive, default: 'Exclusive')
      string = string.gsub('<exclusive>', replace_exclusive)
    end

    if includes_coupon_info_discount?(string)
      replacement_values = top_3_coupons_discount_hash(coupons)
      if replacement_values.present?
        replacement_values.each_pair do |key, value|
          if value.present?
            string.gsub!(key, value)
          else
            string.gsub!(key, '')
          end
        end
      else
        (1..3).map { |number| "<coupon#{number}_info_discount>" }.each do |variable|
          string.gsub!(variable, '')
        end
      end
    end

    string
  end
end
