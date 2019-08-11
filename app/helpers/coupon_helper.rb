module CouponHelper

  def coupon_title_heading
    shop_ids = Setting::get('experimental.shops_with_elevated_coupons', default: []).map(&:to_i)
    return :h3 unless is_shop? && @shop.present? && shop_ids.include?(@shop.id)
    :h2
  end

  def init_shop_filters(coupons)
    shops = coupons.map(&:shop).uniq
    return false if params[:controller] != 'campaigns' || shops.size <= 1
    shops.sort_by(&:title)
  end

  def init_category_filters(coupons)
    categories = coupons.map(&:categories).flatten.uniq
    return false if params[:controller] != 'campaigns' || categories.size <= 1
    categories.sort_by(&:name)

  end

  def clickout_params_for_element(coupon, element=nil)
    return if coupon.has_expired?

    li_clickout_allowed_sites = [1]

    case true
    when element.nil?
      render_clickout_params_string_for coupon
    when element == 'li' && li_clickout_allowed_sites.include?(Site.current.id)
      render_clickout_params_string_for coupon
    when element == 'button' && !li_clickout_allowed_sites.include?(Site.current.id)
      render_clickout_params_string_for coupon
    else
      return
    end
  end

  def coupon_filter_ids(coupon)
    return if coupon.has_expired?
    out = "data-coupon-type='#{coupon.coupon_type}' "
    out += "data-filter-ids='shop-#{coupon.shop_id}x "
    out += coupon.category_ids.map { |c| 'cat-' + c.to_s + 'x' }.join(' ')
    out += "'"
    out.html_safe
  end

  def render_clickout_params_string_for(coupon)
    [
      "data-coupon-id='#{coupon.id}'",
      "data-shop-name='#{coupon.shop_title.gsub("\'", '').html_safe}'",
      "data-coupon-title='#{coupon.title.gsub("\'", '').html_safe}'",
      "data-coupon-url='#{dynamic_url_for('coupon', 'clickout', coupon.id)}'",
      "href='#id-#{coupon.id}'",
      "#{'data-changed-behaviour=\'true\'' unless coupon.has_default_behaviour?}",
      "target='_blank'"
    ].reject(&:empty?).join(' ').html_safe
  end

  def info_fields_string(coupon, type='table')
    info_fields = coupon.info_fields_hash
    return '' unless info_fields.any?

    if type == 'table'
      str = '<table class="coupon-info">'

      info_fields.each do |f|
        str += '<tr>'
        str += "<td><b class='text-ellipsis'>#{t(f[0], default: f[0])}</b></td>"
        str += "<td>#{f[1]}</td>"
        str += '</tr>'
      end

      str += '</table>'
      return str

    elsif type == 'list'
      str = '<ul class="list-unstyled voucher-details space-md-bottom">'

      info_fields.each do |f|
        str += '<li>'
        str += "<cite>#{t(f[0], default: f[0])}</cite>"
        str += "<span>#{f[1]}</span>"
        str += '</tr>'
      end

      str += '</ul>'
      return str
    end
  end

  def data_page_headlines
    data_page_headline = case params[:type]
    when 'popular'
      {
        title: t(:POPULAR_COUPONS_TITLE, default: 'POPULAR_COUPONS_TITLE'),
        subtitle: t(:POPULAR_COUPONS_SUBTITLE, default: 'POPULAR_COUPONS_SUBTITLE')
      }
    when 'exclusive'
      {
        title: t(:EXCLUSIVE_COUPONS_TITLE, default: 'EXCLUSIVE_COUPONS_TITLE'),
        subtitle: t(:EXCLUSIVE_COUPONS_SUBTITLE, default: 'EXCLUSIVE_COUPONS_SUBTITLE')
      }
    when 'new'
      {
        title: t(:NEW_COUPONCODES_TITLE, default: 'NEW_COUPONCODES_TITLE'),
        subtitle: t(:NEW_COUPONCODES_SUBTITLE, default: 'NEW_COUPONCODES_SUBTITLE')
      }
    when 'top'
      {
        title: t(:TOP_COUPONS_TITLE, default: 'TOP_COUPONS_TITLE'),
        subtitle: t(:TOP_COUPONS_SUBTITLE, default: 'TOP_COUPONS_SUBTITLE')
      }
    when 'free_delivery'
      {
        title: t(:FREE_DELIVERY_COUPONS_TITLE, default: 'FREE_DELIVERY_COUPONS_TITLE'),
        subtitle: t(:FREE_DELIVERY_COUPONS_SUBTITLE, default: 'FREE_DELIVERY_COUPONS_SUBTITLE')
      }
    else
      {
        title: t(:EXPIRING_COUPONS_TITLE, default: 'EXPIRING_COUPONS_TITLE'),
        subtitle: t(:EXPIRING_COUPONS_SUBTITLE, default: 'EXPIRING_COUPONS_SUBTITLE')
      }
    end
  end

  def coupon_bookmarked? id
    @saved_coupons ||= saved_coupon_ids
    return @saved_coupons.include?(id.to_s)
  end

  def valid_coupon_type coupon
    if coupon.coupon_type == 'coupon' && coupon.code.present?
      'coupon'
    else
      'offer'
    end
  end

  def bookmarked_coupons_count
    @saved_coupons ||= saved_coupon_ids
    return @saved_coupons.count
  end

  def savings_in_string(coupon, boldify = true)
    coupon.savings_in_string(boldify) if coupon.present?
  end

  # 1) coupon with code & savings & savings_in
  # — show savings and Coupon
  # 2) coupon is top
  # — show top (first) and second line: coupon
  # 3) coupon is free
  # — show free first and second line: coupon
  # 4) is free delivery coupon and offer
  # — show free_delivery (first and second line) red coupon, blue offer
  # 5) is an offer with savings and savings_in
  # — show savings, savings_in and Offer
  # 6) offer is top
  # — show top (first) and second line: Offer
  # 7) offer is free
  # — show free first and second line: offer
  # 8) fallback offer and coupon
  # — show fallback first and second line: offer or coupon, respectively
  def default_logo_text coupon
    texts = default_logo_texts(coupon)
    strip_tags(texts.values.join(' '))
  end

  def default_logo_texts coupon
    case true
    when coupon.logo_text_first_line.present? && coupon.logo_text_second_line.present?
      { first_line: coupon.logo_text_first_line.html_safe, second_line: coupon.logo_text_second_line.html_safe }
    when coupon.coupon_type == 'coupon' && coupon.savings.present? && coupon.savings.to_i > 0
      { first_line: savings_in_string(coupon), second_line: I18n.t(:coupon, default: 'Coupon') }
    when coupon.coupon_type == 'coupon' && coupon.is_top
      { first_line: I18n.t('logo_first_line_top', default: 'Top'), second_line: I18n.t(:coupon, default: 'Coupon') }
    when coupon.coupon_type == 'coupon' && coupon.is_free
      { first_line: I18n.t("logo_first_line_free", default: 'Free'), second_line: I18n.t(:coupon, default: 'Coupon') }
    when coupon.coupon_type == 'offer' && coupon.savings.present? && coupon.savings.to_i > 0
      { first_line: savings_in_string(coupon), second_line:  I18n.t(:offer, default: 'Offer') }
    when coupon.is_free_delivery
      { first_line: I18n.t("logo_first_line_free_delivery", default: 'Free'), second_line: I18n.t("logo_second_line_free_delivery", default: 'Delivery') }
    when coupon.coupon_type == 'offer' && coupon.is_top
      { first_line: I18n.t('logo_first_line_top', default: 'Top'), second_line:  I18n.t(:offer, default: 'Offer')  }
    when coupon.coupon_type == 'offer' && coupon.is_free
      { first_line: I18n.t("logo_first_line_free", default: 'Free'), second_line:  I18n.t(:offer, default: 'Offer')  }
    else
      { first_line: I18n.t('logo_first_line_fallback', default: 'Mega'), second_line: coupon_type_i18n(coupon) }
    end
  end

  def coupon_type_i18n coupon
    coupon.coupon_type == 'coupon' ? I18n.t(:coupon, default: 'Coupon') : I18n.t(:offer, default: 'Offer')
  end

  def saved_coupon_ids
    cookies[:saved_coupons].present? ? cookies[:saved_coupons].split(',') : []
  end

  def coupon_code_btn_text coupon
    if coupon.shop.slug.index('amazon').nil?
      t(:SHOW_COUPON, default: 'Show Coupon')
    else
      coupon_code_btn_text_with_shop_name(coupon)
    end
  end

  def coupon_btn_text coupon
    if coupon.shop.slug.index('amazon').nil?
      t(:SEE_OFFER, default: 'See Offer')
    else
      coupon_btn_text_with_shop_name(coupon)
    end
  end

  def coupon_btn_text_with_shop_name coupon
    t(:GO_TO_SHOP_NAME, default: 'Go To {shop_name}').gsub('{shop_name}', coupon.shop.title)
  end

  def coupon_code_btn_text_with_shop_name coupon
    t(:CODE_FOR_SHOP_NAME, default: 'Go To {shop_name}').gsub('{shop_name}', coupon.shop.title)
  end

end
