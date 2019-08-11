class Resources::V1::Snippets < Grape::API
  helpers do
    def render_shop(shop)
      coupons = @site.coupons_by_shops(shop.id, false).order_by_shop_list_priority
      best_offer = coupons.first

      {
        id: shop.id,
        name: shop.title,
        anchor_text: shop.try(:html_document).try(:dynamic_h1, coupons),
        url: dynamic_url_for('shops', 'show', slug: shop.slug, protocol: @site.site.protocol, utm_source: utm_source, only_path: false),
        logo: shop.logo_url('_200x200'),
        image: shop.header_image_url('_0x120'),
        best_offer_id: best_offer.try(:id),
        best_offer_text: best_offer.try(:title),
        category: shop.api_category_slug
      }
    end

    def utm_source
      return nil unless @site.id == 76
      @utm_source ||= request.referer.to_s.include?('pagesix') ? 'pagesixsnippet' : 'nypostsnippet'
    end

    def tags
      return @tags if @tags.present?

      words = params[:tags].to_s.split(',').map(&:strip)
      @tags = words.map do |word|
        tag = Tag.find_or_create_by(word: word, site: @site.site)
        tag.increment!(:api_hits)
        tag
      end
    end

    def category_slugs
      @category_slugs ||= params[:categories].to_s.gsub(' ', '').split(',')
    end

    def campaign_slugs
      @campaign_slugs ||= params[:campaigns].to_s.gsub(' ', '').split(',')
    end

    def coupons_by_campaign_slugs(limit)
      campaigns = @site.campaigns
        .where(slug: campaign_slugs)
        .order(Arel.sql("find_in_set(campaigns.slug, '#{campaign_slugs.reject(&:blank?).join(',')}')"))

      campaign_coupon_ids = []

      campaigns.each do |campaign|
        campaign_coupon_ids += @site.campaign_coupons(campaign).limit(limit - campaign_coupon_ids.size).pluck('coupons.id')
      end

      return Coupon.includes(:shop).where(id: campaign_coupon_ids).order_by_set(campaign_coupon_ids).limit(limit) if campaign_coupon_ids.present?
      []
    end

    def coupons_by_category_slugs(limit)
      @site.site
        .coupons
        .includes(:shop)
        .active_and_visible
        .by_category_slugs(category_slugs)
        .order_by_exclusive_and_top
        .limit(limit)
    end

    def coupons_by_default(limit)
      coupons = []
      coupons += @site.coupons_by_type('exclusive').group(:shop_id).limit(limit)
      if coupons.count < limit
        top = @site.coupons_by_type('top').group(:shop_id).limit(limit - coupons.count)
        coupons += if coupons.count == 0
          top
        else
          top.where("coupons.id not in (?)", coupons.map(&:id) )
        end
      end
      coupons = (coupons.sort_by{ |c| c.priority_score }).reverse if coupons.present?
    end

    def shops_by_tags(limit)
      return [] if tags.map(&:is_blacklisted).any?

      category_ids = tags.pluck(:category_id).reject(&:blank?).keys_with_highest_frequency
      return [] unless category_ids.present?

      categories = Category.where(id: category_ids.keys)

      shops_by_categories(categories, limit)
    end

    def shops_by_categories(categories, limit)
      excluded_ids = [0]
      shops = []
      tier = 1
      while shops.size < limit && tier <= 4 do
        shops += categories.map do |c|
          result = c.related_shops.by_tier_group(tier).active.where('shops.id not in (?)', excluded_ids).limit(limit).uniq

          result.map do |shop|
            shop.main_category_slug = c.slug
            shop
          end
        end.flatten
        excluded_ids = shops.map(&:id) if shops.present?
        tier += 1
      end
      shops.uniq
    end
  end

  resources :snippet do
    before do
      init_site
      set_surrogate_key_header Site.current.surrogate_key
      set_surrogate_control_header
    end

    desc "Categories used to render a snippet"
    params do
      optional :limit, type: Integer, default: 10
    end
    get :categories do
      categories = @site.categories.active.limit(sanitized_limit)
      set_surrogate_key_header 'categories', 'snippet_categories_index', categories.map(&:resource_key)

      categories.map do |cat|
        {
          id: cat.id,
          slug: cat.slug,
          name: cat.name,
          anchor_text: cat.try(:html_document).try(:dynamic_h1, @site.coupons_by_categories(cat.id)),
          url: dynamic_url_for('categories', 'show', slug: cat.slug, parent_slug: cat.parent_slug, protocol: @site.site.protocol, only_path: false),
        }
      end
    end

    desc "Coupons used to render a snippet, shows top and exclusive coupons"
    params do
      optional :categories, type: String
      optional :campaigns, type: String
      optional :limit, type: Integer, default: 10
    end
    get :coupons do
      if params[:campaigns].present? && params[:categories].present?
        status 400
        return { error: 'Invalid query params! Please use either campaigns OR categories.' }
      end
      limit = sanitized_limit
      coupons = []

      if category_slugs.present?
        coupons = coupons_by_category_slugs(limit)
      elsif campaign_slugs.present?
        coupons = coupons_by_campaign_slugs(limit)
      else
        coupons = coupons_by_default(limit)
      end

      set_surrogate_key_header 'coupons', 'snippet_coupons_index', coupons.map(&:resource_key)

      coupons.map do |c|
        {
          id: c.id,
          shop_name: c.shop.try(:title),
          anchor_text: c.title,
          url: dynamic_url_for('shops', 'show', slug: c.shop_slug, protocol: @site.site.protocol, only_path: false),
          logo: c.shop.logo_url('_200x200'),
          image: c.widget_header_image_url('_0x120')
        }
      end
    end

    desc "Shops used to render a snippet"
    params do
      optional :tags, type: String
      optional :categories, type: String
      optional :limit, type: Integer, default: 10
    end
    get :shops do
      shops = []
      limit = sanitized_limit
      categories = @site.categories.where(slug: category_slugs) if category_slugs.present?

      if tags.present?
        shops = shops_by_tags(limit)
      elsif categories.present?
        shops = shops_by_categories(categories, limit)
      else
        shops = @site.shops.active.order(priority_score: :desc).limit(limit - shops.count)
      end

      set_surrogate_key_header 'shops', 'snippet_shops_index', shops.map(&:resource_key)

      shops.take(limit).map do |shop|
        render_shop(shop)
      end
    end

    desc "Featured Shops used to render a snippet"
    params do
      optional :limit, type: Integer, default: 10
    end
    get 'top-shops' do
      limit = sanitized_limit

      featured_shop_ids = Setting::get('publisher_site.featured_shop_ids', default: []).reject(&:blank?).map(&:to_i)
      shops = @site.shops.where(id: featured_shop_ids).order_by_set(featured_shop_ids).limit(limit)
      shops = shops + @site.shops.visible.with_logo.where('id not in (?)', shops.map(&:id)).order(is_top: :desc).limit(limit - shops.size)

      set_surrogate_key_header 'shops', 'snippet_top_shops_index', shops.map(&:resource_key)

      shops.take(limit).map do |shop|
        render_shop(shop)
      end
    end
  end
end
