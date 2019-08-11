module Breadcrumbs
  extend ActiveSupport::Concern

  included do

    helper_method :breadcrumbs, :add_breadcrumb

    protected

    def add_breadcrumb(name, path = nil, options={})
      self.breadcrumbs << Breadcrumbs::Element.new(name, path, options)
    end

    def breadcrumbs
      @breadcrumbs ||= []
    end

    def add_default_breadcrumbs
      controller = params[:controller]
      action = params[:action]

      if action == 'not_found'
        add_breadcrumb t(:META_TITLE_NOT_FOUND, default: 'META_TITLE_NOT_FOUND')
        return
      end

      case controller
      when 'shops'
        add_breadcrumb I18n.t('shops'), dynamic_url_for('shops', 'index', only_path: false)
        if action == 'show'
          title = @h1.present? ? @h1 : @shop.try(:title)
          if @top_categories.present?
            category = @top_categories.first
            if(category.parent_slug.present?)
              add_breadcrumb category.parent_name, dynamic_url_for('categories', 'show', slug: category.parent_slug, only_path: false)
            end
            add_breadcrumb category.name, dynamic_url_for('categories', 'show', slug: category.slug, parent_slug: category.parent_slug, only_path: false)
          end
          add_breadcrumb title, dynamic_url_for('shops', 'show', slug: @shop.slug, only_path: false) if @shop.present?
        end
      when 'categories'
        add_breadcrumb I18n.t('categories'), dynamic_url_for('categories', 'index', only_path: false)
        if action == 'show'
          if(@category.try(:parent_slug).present?)
            add_breadcrumb @category.parent_name, dynamic_url_for('categories', 'show', slug: @category.parent_slug, only_path: false)
          end
          add_breadcrumb @category.name, dynamic_url_for('categories', 'show', slug: @category.slug, parent_slug: @category.parent_slug, only_path: false)
        end
      when 'bookmarks'
        if action == 'index'
          add_breadcrumb I18n.t(:saved_coupons, default: 'Saved Coupons'), dynamic_url_for('bookmarks', 'index', only_path: false)
        end

      when 'coupons'

        if action == 'index'
          case params[:type]
          when 'popular'
            title = I18n.t('COUPON_LIST_NAV_POPULAR', default: 'COUPON_LIST_NAV_POPULAR')
          when 'new'
            title = I18n.t('COUPON_LIST_NAV_NEW', default: 'COUPON_LIST_NAV_NEW')
          when 'exclusive'
            title = I18n.t('COUPON_LIST_NAV_EXCLUSIVE', default: 'COUPON_LIST_NAV_EXCLUSIVE')
          when 'free_delivery'
            title = I18n.t('COUPON_LIST_NAV_FREE_DELIVERY', default: 'COUPON_LIST_NAV_FREE_DELIVERY')
          when 'expiring'
            title = I18n.t('COUPON_LIST_NAV_EXPIRING', default: 'COUPON_LIST_NAV_EXPIRING')
          else
            title = I18n.t('COUPON_LIST_NAV_TOP', default: 'COUPON_LIST_NAV_TOP')
          end
          add_breadcrumb title, dynamic_url_for('coupons', 'index', type: params[:type], only_path: false)
        end
      when 'mail_forms'
        add_breadcrumb @title
      when 'campaigns'
        if action == 'show' && @campaign.present?
          if @campaign.shop_id.present?
            add_breadcrumb I18n.t('shops'), dynamic_url_for('shops', 'index', only_path: false)
            add_breadcrumb @campaign.shop.title, dynamic_url_for('shops', 'show', slug: @campaign.shop.slug, only_path: false)
          elsif @campaign.parent_id.present?
            add_breadcrumb @campaign.parent.name, dynamic_campaign_url_for(@campaign.parent, only_path: false)
          end
          add_breadcrumb @campaign.name, dynamic_campaign_url_for(@campaign, only_path: false)
        end
      when 'searches'
        add_breadcrumb t(:META_TITLE_SEARCH_PAGE, default: 'META_TITLE_SEARCH_PAGE {search_query}').gsub('{search_query}', @query), dynamic_url_for('searches', 'index', only_path: false)
      end
    end
  end

  # Represents a navigation element in the breadcrumb collection.
  #
  class Element

    # @return [String] The element/link name.
    attr_accessor :name
    # @return [String] The element/link URL.
    attr_accessor :path
    # @return [Hash] The element/link URL.
    attr_accessor :options

    # Initializes the Element with given parameters.
    #
    # @param  [String] name The element/link name.
    # @param  [String] path The element/link URL.
    # @param  [Hash] options The element/link URL.
    # @return [Element]
    #
    def initialize(name, path = nil, options = {})
      self.name     = name
      self.path     = path
      self.options  = options
    end
  end

end
