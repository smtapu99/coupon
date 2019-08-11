require 'digest/md5'

class ShopsController < FrontendController
  before_action :set_metas, only: [:index]
  before_action :check_slug_and_load_shop, only: [:show]
  before_action :check_redirection, only: [:show]

  def index
    @shops = @site.shops.visible.with_active_coupons.order(title: :asc).select('shops.id', 'shops.title', 'shops.slug', 'shops.logo_alt_text')
    @shops_empty = @shops.present? ? @site.shops.visible.where('id not in (?)', @shops.map(&:id)).order(title: :asc) : @site.shops.visible.order(title: :asc).select('shops.id', 'shops.title', 'shops.slug', 'shops.active_coupons_count', 'shops.logo_alt_text')

    featured_shop_ids = Setting::get('publisher_site.featured_shop_ids', default: []).reject(&:empty?).map(&:to_i)
    @shops_featured = Shop.where(id: featured_shop_ids)
    @shops_featured = @shops_featured.visible.with_logo.order(Arel.sql("find_in_set(shops.id, '#{featured_shop_ids}')")).limit(10).select(:id, :slug, :logo, :title, :logo_alt_text, :logo_title_text)
    @shops_featured = @shops_featured + @site.shops.visible.with_logo.where('id not in (?)', @shops_featured.map(&:id)).order(is_top: :desc).limit(10 - @shops_featured.size).select(:id, :slug, :logo, :title, :logo_alt_text, :logo_title_text)
    @shop_category_slugs = @site.shop_category_slugs

    @category_groups = {}
    category_shops_fallback = []
    @shops.each do |shop|
      relevant_category = shop.relevant_categories.select(&:is_active?).first
      if relevant_category.present?
        (@category_groups[relevant_category] ||= []) << shop
      else
        category_shops_fallback << shop
      end
    end

    @category_groups = @category_groups.sort_by { |group| group[0].present? ? group[0].name : '' }
    @category_groups << [nil, category_shops_fallback] if category_shops_fallback.present?
    @category_groups.each do |group|
      if group[0].present?
        category_welcome_text = strip_tags(group[0].html_document.welcome_text)
        group << category_welcome_text
      end
    end

    surrogate_key_header [
      'shops', 'shops_index', @shops_featured.map(&:resource_key)
    ]

    add_default_breadcrumbs
    add_body_tracking_data

    render layout: default_layout
  end

  def show
    if @shop.present?
      @sub_pages = @site.shop_sub_pages(@shop)
      @coupons = @site.coupons_by_shops(@shop.id, false).order_by_shop_list_priority
    end

    if (Setting::get('publisher_site.hide_coupons_of_sub_pages', default: 1).to_i == 1).present? && @sub_pages.present?
      remove_coupon_ids = CampaignsCoupon.where(campaign_id: @sub_pages.pluck(:id)).pluck(:coupon_id)
      if remove_coupon_ids.present?
        @coupons = @coupons.where('coupons.id not in (?)', remove_coupon_ids)
      end
    end

    if params.keys.include?('expired')
      flash.now[:error] = t(:coupon_is_expired_notice, default: 'coupon_is_expired_notice')
      @coupons = @coupons.where('coupons.id != ?', params[:expired].to_i)
    end

    @expired_coupons = @site.inactive_coupons.where(:shop_id => @shop.id).limit(10)

    @top_categories = relevant_categories(@shop)

    if @top_categories.present?
      if is_popular_shop_test?
        relateds = Rails.cache.fetch(['related_shops', @shop, @top_categories.first]) do
          @site.popular_and_related_shops(@shop, @top_categories.first)
        end
        @popular_shops = relateds[:popular]
        @related_shops = relateds[:related]
      else
        if @shop.tier_group > 1
          @popular_shops = category_related_shops_by_tier(@top_categories, @shop.tier_group - 1, 5)
        end
        @related_shops = category_related_shops_by_tier(@top_categories, @shop.tier_group, 15)
      end

      @site.relevant_categories = @top_categories
    end

    @top_coupons = []

    unless @coupons.present?
      @widget = @site.widget('newsletter') || Widget.new(name: 'newsletter')
      @values = widget_values @widget
      @top_coupons = @site.coupons.by_type('top').order(clicks: :desc).limit(10)
    end

    # XXX: custom fallback solution for individual translations for apple shops. check initializers/tms.rb
    I18n.shop_scope = @shop.id

    add_show_metas
    add_show_surrogate_keys
    add_default_breadcrumbs
    add_body_tracking_data

    render layout: params[:only_content].present? ? 'only_content' : default_layout
  end

  def vote
    @shop = Shop.find_by(id: params[:id], status: 'active')

    unless Vote.find_by_keypunch_keys(@shop.id, session[:subIdTracking]).exists?
      respond_to do |format|
        @existed_vote = @shop.add_vote(params[:stars], session[:subIdTracking])
        format.js if @existed_vote.present?
      end
    end
  end

  def render_votes
    head :not_found and return if params[:id].to_i == 0
    respond_to do |format|
      format.js do
        begin
          @shop = @site.shops.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          head :not_found and return
        end
        @existed_vote = Vote.find_by_keypunch_keys(@shop.id, session[:subIdTracking]).first

        render
      end
      format.html { head :not_found }
    end
  end

  private

  def add_show_surrogate_keys
    surrogate_key_header [
      'coupons', @coupons.map(&:resource_key), @expired_coupons.map(&:resource_key),
      @top_coupons.map(&:resource_key), @shop.resource_key
    ]
  end

  def add_show_metas
    content_for :canonical, original_url_with_custom_protocol.split('?').first

    dynamic_pages = Setting::get('admin_rules.dynamic_pages')

    if @shop.present? && @shop.html_document.present?
      init_html_document_vars(@shop.html_document, @coupons)

      content_for :keywords, @meta_keywords.html_safe if @meta_keywords.present?

      if @meta_title.present?
        content_for :title, @meta_title
      elsif @h1.present?
        content_for :title, @h1
      elsif @shop.title.present?
        content_for :title, @shop.title
      end

      if @meta_description.present?
        content_for :description, @meta_description
      elsif @welcome_text.present?
        content_for :description, @welcome_text.truncate(300)
      elsif @h1.present?
        content_for :description, @h1
      end
    end

    if params[:page].present?
      content_for :robots, 'noindex,follow'
    elsif dynamic_pages == 'noindex'
      content_for :robots, 'noindex,nofollow'
    elsif @meta_robots.present?
      content_for :robots, @meta_robots
    else
      content_for :robots, 'index,follow'
    end
  end

  def relevant_categories(shop)
    Rails.cache.fetch([Site.current.id, 'rel_cat', shop.id]) do
      shop.relevant_categories
    end
  end

  def category_related_shops_by_tier(categories, tier, limit = 5)
    Rails.cache.fetch([@site.id, 'crsbt', tier, @shop.id, categories.map(&:updated_at).to_s, limit], :expires_in =>  30.minutes) do
      (categories.map {|c| c.related_shops.active.with_active_coupons.by_tier_group(tier).where("relation_to_id != ?", @shop.id).select('shops.id', 'shops.title', 'shops.logo', 'shops.logo_alt_text', :anchor_text, :slug).order(priority_score: :desc)}).flatten.uniq.take(limit)
    end
  end

  def check_redirection
    if params[:page].present?
      redirect_to url_for(params.except(:page, :theme).merge(only_path: true)), turbolinks: false and return
    end

    not_found and return unless @shop

    unless @shop.is_active?
      return redirect_to_category(@shop.shop_categories.first) if @shop.shop_categories.present?
      return render_404 if @shop.is_gone?
      return redirect_to_home if @shop.is_blocked? || @shop.is_pending?
    end
  end

  def check_slug_and_load_shop
    slug = params[:slug]
    if slug.present? && slug =~ /[A-Z]/
      redirect_to dynamic_url_for('shops', 'show', slug: slug.downcase, params: cleanup_params), status: :moved_permanently
    end
    @shop = @site.site.shops.find_by(slug: slug.downcase)
  end

  def cleanup_params
    ['action', 'controller', 'host', 'slug', 'theme'].each do |p|
      params.delete(p.to_sym)
    end
    params
  end

  def widget_values widget
    widget.defaults.merge( widget.value.marshal_dump.select {|k, v| v.present?} )
  end

  def set_metas
    content_for :canonical, original_url_with_custom_protocol
    content_for :title, t(:META_TITLE_SHOP_OVERVIEW, default: 'META_TITLE_SHOP_OVERVIEW').html_safe

    dynamic_pages = Setting::get('admin_rules.dynamic_pages')

    if params[:only_content].present?
      content_for :robots, 'noindex,follow'
    elsif dynamic_pages.present? && dynamic_pages == 'noindex'
      content_for :robots, 'noindex,nofollow'
    else
      content_for :robots, 'index,follow'
    end
  end
end
