module VueData
  class Quality::ActiveCoupons < VueData::Quality
    include ActionView::Helpers::UrlHelper

    private

    def records_paginated
      base = records.page(page).per(per_page)

      case order.to_sym
      when :today
        base.order(active_coupons_count: direction)
      when :"3_days", :"7_days"
        days = order.first
        base.join_active_coupons_in_days(days.to_i).order(Arel.sql("COUNT(coupons.id) #{direction}"))
      else
        base.order(order => direction)
      end
    end

    def records
      ::Shop::active_coupons_filter(params)
    end

    def data(record)
      {
        id: record.id,
        tier_group: record.tier_group,
        status: record.status,
        title: record.title,
        slug: record.slug,
        is_top: record.is_top,
        is_hidden: record.is_hidden,
        priority_score: record.priority_score,
        today: record.active_coupons_count,
        best_offer_valid: link_to_edit_coupon(record),
        '3_days' => record.coupons.active_in_days(3).count,
        '7_days' => record.coupons.active_in_days(7).count
      }
    end

    def link_to_edit_coupon(record)

      coupon = SiteFacade.new(record.site).coupons_by_shops(record.id, false).order_by_shop_list_priority.first

      if coupon.present?
        path = Rails.application.routes.url_helpers.edit_admin_coupon_path(id: coupon.id)
        valid = coupon.title.include?(record.title)
        css_class = valid ? 'btn-success' : 'btn-danger'
      else
        path = Rails.application.routes.url_helpers.new_admin_coupon_path()
        valid = 'Not found'
        css_class = 'btn-warning'
      end
      "<a class='btn #{css_class}' href=#{path}>#{valid}</a>"
    end
  end
end
