require 'vue_data/campaign_import'

module Admin
  class CampaignImportsController < BaseController
    before_action :authenticate_admin_user!
    before_action :set_campaign_import, only: [:edit, :destroy]

    load_and_authorize_resource

    def index
      respond_to do |format|
        format.json { render json: VueData::CampaignImport.render_json(nil, params), status: :ok }
        format.html
      end
    end

    def edit
    end

    # POST /admin/campaign_imports
    # POST /admin/campaign_imports.json
    def create
      @campaign_import = CampaignImport.new(campaign_import_params)
      @campaign_import.user_id = User.current.id
      @campaign_import.status  = 'pending'

      respond_to do |format|
        if @campaign_import.save
          Resque.enqueue(CampaignImportWorker, @campaign_import.id)
          format.html { redirect_to admin_campaign_imports_path, notice: 'Campaign Import placed into queue. Please check the status below.' }
        else
          @campaign_import.update_attribute(:status, 'error')
          format.html { redirect_to new_admin_campaign_import_path, notice: 'An Error occurred during the file upload.' }
        end
      end
    end

    # POST /admin/campaign_imports
    # POST /admin/campaign_imports.json
    def create_old
      site = Site.current
      user = User.current

      if site.nil?
        flash[:error] = 'Please select a valid Site'
        redirect_to action: :new and return
      else
        Time.zone = site.time_zone.present? ? site.time_zone : 'Berlin'
        @campaign_import = CampaignImport.new(campaign_import_params.merge(user_id: user.id))

        respond_to do |format|
          if @campaign_import.save && @campaign_import.run
            format.html { redirect_to admin_campaigns_url, notice: 'Campaigns were successfully imported.' }
          else
            format.html { render action: 'new' }
          end
        end
      end
    end

    # DELETE /admin/campaign_import/1
    # DELETE /admin/campaign_import/1.json
    def destroy
      @admin_campaign_import.destroy
      respond_to do |format|
        format.json { head :ok }
      end
    end

    private

    def set_campaign_import
      @admin_campaign_import = CampaignImport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_import_params
      params.require(:campaign_import).permit(:file)
    end
  end
end
