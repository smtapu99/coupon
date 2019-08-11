require 'vue_data/coupon_import'

module Admin
  class CouponImportsController < BaseController
    before_action :authenticate_admin_user!
    before_action :set_coupon_import, only: [:edit, :destroy]

    load_and_authorize_resource

    def index
      respond_to do |format|
        format.json { render json: VueData::CouponImport.render_json(nil, params), status: :ok }
        format.html
      end
    end

    # POST /admin/coupon_imports
    # POST /admin/coupon_imports.json
    def create
      redirect_to new_admin_coupon_import_path and return unless params[:coupon_import].present?

      @coupon_import = CouponImport.new(coupon_import_params)
      @coupon_import.user_id = User.current.id
      @coupon_import.status  = 'pending'

      respond_to do |format|
        if @coupon_import.save
          Resque.enqueue(CouponImportWorker, @coupon_import.id)
          format.html { redirect_to admin_coupon_imports_path, notice: 'Coupons Import placed into queue. Please check the status below.' }
        else
          format.html { render action: :new  }
        end
      end
    end

    def edit
    end

    # DELETE /admin/coupon_imports/1
    # DELETE /admin/coupon_imports/1.json
    def destroy
      @admin_coupon_import.destroy
      respond_to do |format|
        format.json { head :ok }
      end
    end

    # POST /admin/coupon_imports
    # POST /admin/coupon_imports.json
    #
    # !!! DONT DELETE THIS METHOD  ---- ITS USED FOR DEBUGING
    def create_old
      # this sets the timezone for the imported coupons to the timezone of the selected site
      site = Site.find(coupon_import_params[:site_id]) rescue Site.current

      if site.nil?
        flash[:error] = 'Please select a valid Site'
        redirect_to action: :new and return
      else
        Time.zone = site.time_zone.present? ? site.time_zone : 'Berlin'

        @coupon_import = CouponImport.new(coupon_import_params)
        @coupon_import.user_id = User.current.id
        @coupon_import.status  = 'pending'

        respond_to do |format|
          # disable second level cache here to avoid the NameError: Uninitialized Constant Spreadsheet
          @saved = @coupon_import.run

          if @saved
            format.html { redirect_to admin_coupons_url, notice: 'Coupons were successfully imported.' }
          else
            format.html { render action: 'new' }
          end
        end
      end
    end

    private

      def set_coupon_import
        @admin_coupon_import = CouponImport.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def coupon_import_params
        params.require(:coupon_import).permit(:site_id, :file)
      end
  end
end
