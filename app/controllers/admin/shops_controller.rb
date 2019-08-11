require 'vue_data/shop'

module Admin
  class ShopsController < BaseController

    include ActsAsActiveCouponsCounter
    include ActsAsPriorityUpdater

    include Admin::CacheHelper
    include ApplicationHelper
    # include Rails.application.routes.url_helpers

    before_action :authenticate_admin_user!
    load_and_authorize_resource except: [:render_shops_select]

    before_action :authorize_reset_votes, only: [:change_status]
    before_action :set_shop, only: [:edit, :update, :order_coupons]
    after_action :set_download_complete_cookie,  only: [:export]
    after_action :purge_proxy_cache, only: [:update, :update_shop_list_priority]

    def verified_request?
      if request.xhr?
        true
      else
        super()
      end
    end

    # GET /admin/shops
    # GET /admin/shops.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Shop.render_json(Site.current.id, params), status: :ok }
        format.html
      end
    end

    # GET /admin/shops/new
    def new
      @shop = Shop.new
    end

    # GET /admin/shops/1/edit
    def edit
    end

    # POST /admin/shops
    # POST /admin/shops.json
    def create
      @shop = Shop.new(shop_params)

      respond_to do |format|
        if @shop.save
          @shop.purge_key('shops_index ' + @shop.resource_key)
          @shop.update_active_coupons_count

          format.html { redirect_to({ :action => 'index' }, :notice => 'Shop was successfully created.') }
          format.json { render action: 'show', status: :created, location: @shop }
        else
          format.html { render action: 'new' }
          format.json { render json: @shop.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/shops/1
    # PATCH/PUT /admin/shops/1.json
    def update
      @shop.slug_mutable = 1 if User.current.is_admin?

      respond_to do |format|
        if @shop.update(shop_params)
          @shop.purge_key('shops_index ' + @shop.resource_key)

          format.html { redirect_to({ :action => 'index' }, :notice => 'Coupon was successfully updated.') }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @shop.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /admin/shops/change_status
    def change_status
      @params = request.params
      @ids = @params[:ids]
      @ids.each do |id|
        shop = Shop.find(id)
        next unless shop.present?

        if %w[hidden visible].include?(@params[:status])
          shop.update(is_hidden: @params[:status] == 'hidden')
        elsif @params[:status] == 'reset_votes'
          Vote.where(shop_id: shop.id).destroy_all
          shop.update(total_votes: 0, total_stars: 0)
        else
          shop.update(status: @params[:status])
        end

        update_active_coupons_count_for shop
        update_priority_for shop

        shop.purge_key('shops_index ' + shop.resource_key)
      end

      render json: @params
    end

    # GET /admin/shops/order_coupons
    def order_coupons
      @site = SiteFacade.new(Site.current)
      @settings = @site.settings
      @coupons = @site.coupons_by_shops(params[:id], false).order_by_shop_list_priority
    end

    def update_coupon_order
      params[:coupon_order].each_with_index do |id, index|
        coupon = Coupon.find_by(id: id, site_id: Site.current.id)
        coupon.update_attribute(:order_position, index) if coupon.present?
      end
      head :ok
    end

    def update_shop_list_priority
      params[:shop_list_priority].each do |id, value|
        @shop = Shop.find(params[:id])
        coupon = Coupon.find_by(id: id, site_id: Site.current.id)
        coupon.update_attribute(:shop_list_priority, value) if coupon.present?
      end
      redirect_to admin_shops_order_coupons_path(id: params[:id])
    end

    def export_modal
      @shop = Shop.new
      respond_to do |format|
        format.js
      end
    end

    def synch_keywords
      @message = 'Started keyword synhronization with googlesheet https://tinyurl.com/ycp4jp37'

      Resque.enqueue(CronWorker, 'shop_keywords:synchronize')

      respond_to do |format|
        format.js { render 'keyword_confirmation' }
      end
    end

    def export
      csv_export = CsvExport.new(export_type: 'Shop', params: params[:shop])
      csv_export.user_id = User.current.id

      respond_to do |format|
        if csv_export.save
          Resque.enqueue(CsvExportWorker, csv_export.id)
          format.html { redirect_to admin_csv_exports_path, notice: 'File is beeing processed' }
        else
          csv_export.update_attribute(:status, 'error')
          redirect_to 'index', notice: 'Error while processing the requested file'
        end
      end
    end

    def import_template
      @shops = Shop.where('1=0')
      render 'export', formats: :xlsx, layout: false, filename: "shops_import_template_#{Time.zone.now.to_date}"
    end

    # keep me for easier debugging
    def export_old
      @shops = Shop.export(params[:shop])
      render 'export', formats: :xlsx, layout: false, filename: "shops_#{Time.zone.now.to_date}"
    end

    # GET /admin/shops/assign_user
    def assign_user
      @params = request.params
      @ids = @params[:ids]

      @ids.each do |id|
        Shop.find(id).update(person_in_charge_id: @params[:person_in_charge_id])
      end

      render json: @params
    end

    def render_shops_select
      return if params[:site_ids].empty?

      respond_to do |format|
        @sites = Site.where(id: params[:site_ids])
        format.html { render partial: 'shops_by_site_select', locals: { sites: @sites } }
      end
    end

    private

    def authorize_reset_votes
      authorize! :reset_votes, Shop if params[:status] == 'reset_votes'
    end

    def purge_proxy_cache
      return unless @shop.site.present?

      url = dynamic_url_for('shops', 'show', slug: @shop.slug, host: @shop.site.hostname, only_path: false)
      CacheService.new(@shop.site).purge(url)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_shop
      @shop = Shop.find_by(id: params[:id], site_id: Site.current.id) || not_found
    end

    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def shop_params
      params.require(:shop).permit(
        :is_top,
        :global_id,
        :title,
        :url,
        :is_hidden,
        :is_default_clickout,
        :is_direct_clickout,
        :anchor_text,
        :tier_group,
        :fallback_url,
        :slug,
        :link_title,
        :logo,
        :logo_alt_text,
        :coupon_targeting_script,
        :remove_logo,
        :remove_header_image,
        :remove_first_coupon_image,
        :person_in_charge_id,
        :prefered_affiliate_network_id,
        :logo_title_text,
        :merchant_id,
        :header_image,
        :first_coupon_image,
        :clickout_value,
        :slug,
        :status,
        :info_address,
        :info_phone,
        :info_free_shipping,
        :site_ids,
        shop_category_ids: [],
        info_payment_methods: [],
        info_delivery_methods: [],
        html_document_attributes: [
          :meta_robots,
          :meta_keywords,
          :meta_description,
          :meta_title,
          :meta_title_fallback,
          :content,
          :welcome_text,
          :h1,
          :h2,
          :htmlable_id,
          :htmlable_type,
          :head_scripts
        ]
      )
    end
  end
end
