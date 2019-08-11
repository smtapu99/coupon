require 'vue_data/site'

module Admin
  class SitesController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_site, only: [:edit, :update]

    # GET /admin/sites
    # GET /admin/sites.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Site.render_json(nil, params), status: :ok }
        format.html
      end
    end

    # GET /admin/sites/new
    def new
      @site = Site.new
    end

    # GET /admin/sites/1/edit
    def edit
    end

    # POST /admin/sites
    # POST /admin/sites.json
    def create
      @site = Site.new(site_params)
      @site.setting = Setting.new

      respond_to do |format|
        if @site.save
          format.html { redirect_to admin_sites_url, notice: 'Site was successfully created.' }
          format.json { render action: 'show', status: :created, location: @site }
        else
          format.html { render action: 'new' , notice: 'An error occured'}
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/sites/1
    # PATCH/PUT /admin/sites/1.json
    def update
      respond_to do |format|
        if @site.update(site_params)
          format.html { redirect_to admin_sites_url, notice: 'Site was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_site
        # @site = Site.find(params[:id])
        @site = Site.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def site_params
        params.require(:site).permit(
          :status,
          :name,
          :hostname,
          :asset_hostname,
          :country_id,
          :time_zone,
          :commission_share_percentage,
          :is_multisite,
          :is_wls,
          :subdir_name,
          :create_like_site_id
          )
      end
  end
end
