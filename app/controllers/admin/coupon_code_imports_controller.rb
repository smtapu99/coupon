module Admin
  class CouponCodeImportsController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    # POST /admin/coupon_codes_import
    # POST /admin/coupon_codes_import.json
    def create

      # this sets the timezone for the imported coupons to the timezone of the site
      site = Site.current

      Time.zone = site.time_zone.present? ? site.time_zone : 'Berlin'

      @coupon_code_import = CouponCodeImport.new(coupon_code_import_params.merge(site_id: site.id))

      respond_to do |format|
        # disable second level cache here to avoid the NameError: Uninitialized Constant Spreadsheet
        @saved = @coupon_code_import.run


        if @saved
          format.html { redirect_to admin_coupon_codes_url, notice: 'Coupon Codes were successfully imported.' }
          format.json { render action: 'new', status: :created, location: @coupon }
        else
          format.html { render action: 'new' }
          format.json { render json: @coupon_code_import.errors, status: :unprocessable_entity }
        end
      end
    end

    private
      # Never trust parameters from the scary internet, only allow the white list through.
      def coupon_code_import_params
        params.require(:coupon_code_import).permit(:site_id, :file)
      end
  end
end
