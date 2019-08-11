require 'vue_data/coupon_code'

module Admin
  class CouponCodesController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_coupon_code, only: [:edit, :update]

    # GET /admin/coupon_codes
    # GET /admin/coupon_codes.json
    def index
      respond_to do |format|
        format.json { render json: VueData::CouponCode.render_json(Site.current.id, params), status: :ok }
        format.html
      end
    end

    # GET /admin/coupon_codes/new
    def new
      @coupon_code = CouponCode.new
      @coupon_code.coupon_id = params[:coupon_id]
    end

    # GET /admin/coupon_codes/1/edit
    def edit
    end

    # POST /admin/coupon_codes
    # POST /admin/coupon_codes.json
    def create
      @coupon_code = CouponCode.new(coupon_code_params)

      respond_to do |format|
        if @coupon_code.save
          format.html { redirect_to admin_coupon_codes_url, notice: 'Coupon Code was successfully created.' }
          format.json { render action: 'show', status: :created, location: @coupon_code }
        else
          format.html { render action: 'new' }
          format.json { render json: @coupon_code.errors, status: :unprocessable_entity }
        end
      end
    end

    def approve_imported
      if Site.current.present?
        imported_coupons = Site.current.coupon_codes.where(is_imported: 1).update_all(is_imported: 0)
        redirect_to admin_coupon_codes_path(anchor: '1'), notice: imported_coupons.to_s + ' imported coupon codes set active'
      else
        redirect_to admin_coupon_codes_path(anchor: '0'), flash: { error: 'You are not allowed to call this action' }
      end
    end

    def remove_imported
      if Site.current.present?
        imported_coupons = Site.current.coupon_codes.where(is_imported: 1).delete_all
        redirect_to admin_coupon_codes_path(anchor: '1'), notice: imported_coupons.to_s + ' imported coupon codes removed'
      else
        redirect_to admin_coupon_codes_path(anchor: '0'), flash: { error: 'You are not allowed to call this action' }
      end
    end

    # PATCH/PUT /admin/coupon_codes/1
    # PATCH/PUT /admin/coupon_codes/1.json
    def update
      respond_to do |format|
        if @coupon_code.update(coupon_code_params)
          format.html { redirect_to admin_coupon_codes_url, notice: 'Coupon Code was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @coupon_code.errors, status: :unprocessable_entity }
        end
      end
    end

    def export
      @coupon_codes = CouponCode.export(params[:coupon_code])
      filename = "coupon_codes_#{Time.zone.now.to_date}"
      response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.xlsx"'
      render 'export', formats: :xlsx, layout: false
    end

    def export_modal
      @coupon_code = CouponCode.new
      respond_to do |format|
        format.js
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_coupon_code
        @coupon_code = CouponCode.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def coupon_code_params
        params.require(:coupon_code).permit(:coupon_id, :code, :tracking_user_id, :used_at, :end_date)
      end
  end
end
