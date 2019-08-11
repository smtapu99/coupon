class Resources::V1::Coupons < Grape::API

  helpers do

    def tracking_user
      TrackingUser.create(
        site_id: @site.site.id,
        referrer: @site.site.hostname,
        uniqid: SecureRandom.urlsafe_base64(23)
      )
    end

    def render_coupon(coupon)
      {
        id: coupon.id,
        shop_id: coupon.shop_id,
        # category_ids: coupon.category_ids,
        title: coupon.title,
        description: coupon.description,
        savings: coupon.savings_in_string(false),
        type: coupon.coupon_type,
        code: coupon.code,
        use_uniq_codes: coupon.use_uniq_codes,
        info_fields: coupon.info_fields_hash,
        logo: coupon.coupon_or_shop_logo,
        image: coupon.widget_header_image_url('_0x120'),
        clickout_url: "https://#{@site.site.hostname}/api-clickout/#{coupon.id}",
        start_date: coupon.start_date.iso8601,
        end_date: coupon.end_date.iso8601,
      }
    end

    def pagination_params
      {
        limit: sanitized_limit(100),
        offset: sanitized_offset
      }
    end

    def filter_params
      filter_params = {}
      if params[:category_slugs].present?
        filter_params[:by_category_slugs] = sanitized_csv(params[:category_slugs])
      end
      if params[:shop_ids].present?
        filter_params[:by_shops] = sanitized_csv(params[:shop_ids])
        filter_params[:order_by_shop_list_priority] = nil
      end
      if params[:category_ids].present?
        filter_params[:by_categories] = sanitized_csv(params[:category_ids])
        filter_params[:order_by_priority] = nil
      end
      filter_params
    end
  end

  resources :coupons do

    before { init_site }

    desc "Return all coupons. Limit is 100 shops at a time"
    params do
      optional :limit, type: Integer, desc: "limit (max: 100)", default: 100
      optional :offset, type: Integer, desc: "offset", default: 0
      optional :shop_ids, type: String, desc: 'List of Shop IDs, (e.g. 123,124)'
      optional :category_ids, type: String, desc: 'List of Category IDs, (e.g. 123,124)'
      optional :category_slugs, type: String, desc: 'List of Category Slugs, (e.g. slug1,slug2)'
    end

    get '/' do
      unpaginated = @site.site.coupons.includes(:shop).active_and_visible.with_filter(filter_params)

      records = unpaginated.with_filter(pagination_params).map { |coupon| render_coupon(coupon) }
      formatted_output('coupons', records, unpaginated.count, pagination_params[:limit], pagination_params[:offset])
    end

    desc "Return a single coupon"
    get ':id' do
      coupon = @site.coupons.find_by(id: params[:id])
      return render_coupon(coupon) if coupon.present?
      {}
    end

    desc "Return a single unique coupon code; or a fallback in case no codes exist"
    get ':id/code' do
      coupon = @site.coupons.find_by(id: params[:id])
      return {} if !coupon.present? || !coupon.use_uniq_codes || coupon.coupon_type == 'offer'

      {
        coupon_id: coupon.id,
        code: coupon.uniq_coupon_code(tracking_user)
      }
    end
  end
end
