require 'vue_data/coupon'

module Admin
  class CouponsController < BaseController
    include ActsAsActiveCouponsCounter
    include ActsAsPriorityUpdater
    include ApplicationHelper

    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_coupon, only: [:edit, :update, :coupon_codes]
    after_action :set_download_complete_cookie,  only: [:export]

    # GET /admin/coupons
    # GET /admin/coupons.json
    def index
      respond_to do |format|
        format.html
        format.json { render json: ::VueData::Coupon.render_json(Site.current.id, params), status: :ok }
      end
    end

    # GET /admin/coupons/new
    def new
      @coupon = Coupon.new
      @coupon.shop_id = coupon_params[:shop_id] if coupon_params[:shop_id].present? rescue nil
    end

    # GET /admin/coupons/1/edit
    def edit
    end

    # POST /admin/coupons
    # POST /admin/coupons.json
    def create
      @coupon = Coupon.new(coupon_params)

      respond_to do |format|
        if @coupon.save
          purge_proxy_cache
          @coupon.update_associated_active_coupons_counts

          format.html { redirect_to({ :action => 'index' }, :notice => 'Coupon was successfully created.') }
          format.json { render action: 'show', status: :created, location: @coupon }
        else
          format.html { render action: 'new' }
          format.json { render json: @coupon.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/coupons/1
    # PATCH/PUT /admin/coupons/1.json
    def update
      respond_to do |format|
        if @coupon.update(coupon_params)
          purge_proxy_cache
          @coupon.purge_key('coupons_index ' + @coupon.resource_key)

          format.html { redirect_to({ :action => 'index' }, :notice => 'Coupon was successfully updated.') }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @coupon.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /admin/coupons/change_status
    def change_status
      @params = request.params
      @ids = @params[:ids]

      @ids.each do |id|
        coupon = Coupon.find(id)
        next unless coupon.present?
        coupon.update_attribute(:status, @params[:status])
        update_active_coupons_count_for coupon
        update_priority_for coupon

        coupon.purge_key('coupons_index ' + coupon.resource_key)
        CacheService.new(coupon.site).purge(dynamic_url_for('shops', 'show', slug: coupon.shop.slug, host: coupon.site.hostname, only_path: false))
      end

      render json: @params
    end

    def export_modal
      @coupon = Coupon.new
      respond_to do |format|
        format.js
      end
    end

    def export
      csv_export = CsvExport.new(export_type: 'Coupon', params: params[:coupon])
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
      @coupons = Coupon.where('1=0')
      render 'export', formats: :xlsx, layout: false, filename: "coupon_import_template_#{Time.zone.now.to_date}"
    end

    def coupon_codes
      respond_to do |format|
        if params[:f].present?
          params[:f].merge!(coupon_id: params[:id])
        else
          params[:f] = { coupon_id: params[:id] }
        end

        format.json { render json: VueData::CouponCode.render_json(Site.current.id, params), status: :ok }
        format.html { render template: 'admin/coupon_codes/index' }
      end
    end

    def export_old
      @coupons = Coupon.export(params[:coupon])
      render xlsx: 'export', layout: false, filename: "coupons_#{Time.zone.now.to_date}"
    end

    private

    def purge_proxy_cache
      url = dynamic_url_for('shops', 'show', slug: @coupon.shop.slug, host: @coupon.site.hostname, only_path: false)
      CacheService.new(Site.current).purge(url)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_coupon
      @coupon = Coupon.find_by(id: params[:id], site_id: Site.current.id) || not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coupon_params
      params.require(:coupon).permit(
        :is_top,
        :is_exclusive,
        :is_editors_pick,
        :is_free,
        :is_mobile,
        :affiliate_network_id,
        :shop_list_priority,
        :is_free_delivery,
        :negative_votes,
        :positive_votes,
        :is_hidden,
        :title,
        :coupon_type,
        :url,
        :code,
        :description,
        :start_date,
        :status,
        :use_uniq_codes,
        :shop_id,
        :campaign_id,
        :end_date,
        :clicks,
        :savings,
        :savings_in,
        :currency,
        :order_position,
        :logo,
        :remove_logo,
        :remote_logo_url,
        :widget_header_image,
        :remove_widget_header_image,
        :info_discount,
        :include_expired,
        :info_min_purchase,
        :info_limited_clients,
        :info_limited_brands,
        :info_conditions,
        :l,
        :sl,
        :origin_coupon_form,
        :logo_text_first_line,
        :logo_text_second_line,
        :use_logo_on_home_page,
        :use_logo_on_shop_page,
        category_ids: [],
        campaign_ids: [],
        shop_ids: []
      )
    end
  end
end
