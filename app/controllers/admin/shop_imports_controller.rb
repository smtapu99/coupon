require 'vue_data/shop_import'

module Admin
  class ShopImportsController < BaseController
    before_action :authenticate_admin_user!
    before_action :set_shop_import, only: [:edit, :destroy]

    load_and_authorize_resource

    def index
      respond_to do |format|
        format.json { render json: VueData::ShopImport.render_json(nil, params), status: :ok }
        format.html
      end
    end

    # POST /admin/shop_imports
    # POST /admin/shop_imports.json
    def create
      @shop_import = ShopImport.new(shop_import_params)
      @shop_import.user_id = User.current.id
      @shop_import.status  = 'pending'

      respond_to do |format|
        if @shop_import.save
          Resque.enqueue(ShopImportWorker, @shop_import.id)
          format.html { redirect_to admin_shop_imports_path, notice: 'Shop Import placed into queue. Please check the status below.' }
        else
          format.html { render action: :new  }
        end
      end
    end

    def edit
    end

    # DELETE /admin/shop_imports/1
    # DELETE /admin/shop_imports/1.json
    def destroy
      @admin_shop_import.destroy
      respond_to do |format|
        format.json { head :ok }
      end
    end

    # POST /admin/shop_imports
    # POST /admin/shop_imports.json
    #
    # # !!! DONT DELETE THIS METHOD  ---- ITS USED FOR DEBUGING SHOP_IMPORT.RB
    def create_old
      PublicActivity.enabled = false

      # this sets the timezone for the imported shops to the timezone of the selected site
      site = Site.find(shop_import_params[:site_id]) rescue Site.current

      if site.nil?
        flash[:error] = 'Please select a valid Site'
        redirect_to action: :new and return
      else
        Time.zone = site.time_zone.present? ? site.time_zone : 'Berlin'

        @shop_import = ShopImport.new(shop_import_params.merge(site_id: site.id))
        @shop_import.user_id = User.current.id
        @shop_import.site_id = Site.current.id
        @shop_import.status  = 'pending'

        respond_to do |format|
          # disable second level cache here to avoid the NameError: Uninitialized Constant Spreadsheet
          @saved = @shop_import.run

          if @saved
            format.html { redirect_to admin_shops_url, notice: 'Shops were successfully imported.' }
            format.json { render action: 'new', status: :created, location: @shop }
          else
            format.html { render action: 'new' }
            format.json { render json: @shop_import.errors, status: :unprocessable_entity }
          end
        end
      end
    end

    private

      def set_shop_import
        @admin_shop_import = ShopImport.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def shop_import_params
        params.require(:shop_import).permit(:site_id, :file)
      end
  end
end
