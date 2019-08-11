class Widgets::FeaturedCouponsService < Widgets::BaseService
  private

  def load_widget_data
    limit = 6
    @coupons = []
    @category = nil

    fallback = @site.coupons

    if @widget.coupon_ids.present?
      @coupons = fallback.where(id: @widget.coupon_ids.split(',')).reorder('find_in_set(coupons.id, "' + @widget.coupon_ids.to_s + '")')
    end

    fallback = fallback.where.not(id: @coupons.pluck(:id))
    emergency_fallback = fallback

    begin
      @category = @site.categories.find(@widget.category) if @widget.category.present?

      if @coupons.count < limit
        if @widget.category.present?
          fallback = fallback.by_categories(@widget.category).where.not(id: @coupons.map(&:id))
        end
        # keep both conditions separate so that they stack up
        if @widget.shop.present?
          fallback = fallback.by_shops(@widget.shop).where.not(id: @coupons.map(&:id))
        end
      end

      query = case @widget.featured_coupons_type
      when 'last_chance'
        fallback.by_type('expiring')
      when 'top_coupons'
        fallback.by_type('top')
      when 'exclusive_coupons'
        fallback.by_type('exclusive')
      else
        fallback
      end

      query = query.joins(:shops_html_document)

      if @widget.shop.present?
        @coupons += query.where.not(id: @coupons.map(&:id)).with_valid_coupon_type('coupon').limit(limit).order_by_priority
        @coupons += query.where.not(id: @coupons.map(&:id)).with_valid_coupon_type('offer').limit(limit).order_by_priority if @coupons.size < limit
      else
        @coupons += query.where.not(id: @coupons.map(&:id)).one_by_shop.with_valid_coupon_type('coupon').limit(limit).order_by_priority
        @coupons += query.where.not(id: @coupons.map(&:id)).one_by_shop.with_valid_coupon_type('offer').limit(limit).order_by_priority if @coupons.size < limit
      end

      if @coupons.size < limit
        if @widget.shop.present?
          @coupons += fallback.where.not(id: @coupons.map(&:id)).with_valid_coupon_type('coupon').limit(limit - @coupons.size).order_by_priority
          @coupons += fallback.where.not(id: @coupons.map(&:id)).with_valid_coupon_type('offer').limit(limit - @coupons.size).order_by_priority if @coupons.size < limit
        else
          @coupons += fallback.where.not(id: @coupons.map(&:id)).one_by_shop.with_valid_coupon_type('coupon').limit(limit - @coupons.size).order_by_priority
          @coupons += fallback.where.not(id: @coupons.map(&:id)).one_by_shop.with_valid_coupon_type('offer').limit(limit - @coupons.size).order_by_priority if @coupons.size < limit
        end
      end
    rescue
      @coupons = emergency_fallback.take(limit)
      @coupons_belong_to_same_shop = coupons_belong_to_same_shop?
      return
    end

    @coupons = @coupons.take(limit)

    if @coupons.count < limit
      @coupons += @site.coupons.where.not(id: @coupons.map(&:id)).one_by_shop.order_by_priority.limit(limit - @coupons.count)
    end

    @coupons_belong_to_same_shop = coupons_belong_to_same_shop?
  end

  def coupons_belong_to_same_shop?
    @coupons.map(&:shop_id).uniq.count == 1 if @coupons.present?
  end
end
