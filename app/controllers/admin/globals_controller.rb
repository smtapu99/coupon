require 'vue_data/global/base'
require 'vue_data/global/shop_mapping'

module Admin
  class GlobalsController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource except: [:shop_mappings, :update_shop_mapping]

    before_action :set_global, only: [:edit, :update]
    before_action :set_shop_mapping, only: [:update_shop_mapping]

    # GET /admin/globals
    # GET /admin/globals.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Global::Base.render_json(nil, params), status: :ok }
        format.html
      end
    end

    # GET /admin/globals/new
    def new
      @global = Global.new
    end

    # GET /admin/globals/1/edit
    def edit
    end

    # POST /admin/globals
    # POST /admin/globals.json
    def create
      @global = Global.new(global_params)

      respond_to do |format|
        if @global.save
          format.html { redirect_to admin_globals_url, notice: 'Global was successfully created.' }
          format.json { render action: 'show', status: :created, location: @global }
        else
          format.html { render action: 'new' }
          format.json { render json: @global.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/globals/1
    # PATCH/PUT /admin/globals/1.json
    def update
      respond_to do |format|
        if @global.update(global_params)
          format.html { redirect_to admin_globals_url, notice: 'Global was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @global.errors, status: :unprocessable_entity }
        end
      end
    end

    def export_modal
      @global = Global.new
      respond_to do |format|
        format.js
      end
    end

    def export
      csv_export = CsvExport.new(export_type: 'Global', params: params[:global])
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

    def shop_mappings
      @country_id = params.dig(:f, :country_id)
      @country_id = Site.current&.country_id if @country_id.nil?
      @country_id = Country.first.id if @country_id.nil?

      respond_to do |format|
        format.json { render json: VueData::Global::ShopMapping.render_json(nil, params.merge(country_id: @country_id)), status: :ok }
        format.html
      end
    end

    def update_shop_mapping
      authorize! :manage, Global

      @shop_mapping.assign_attributes(shop_mapping_params)
      if @shop_mapping.save
        render json: @shop_mapping, status: :created
      else
        render json: @shop_mapping.errors, status: :unprocessable_entity
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_global
      @global = Global.find(params[:id]) || not_found
    end

    def set_shop_mapping
      @shop_mapping = Global::ShopMapping.find_or_initialize_by(global_id: shop_mapping_params[:id], country_id: shop_mapping_params[:country_id])
    end

    def global_params
      params.require(:global).permit(
        :name,
        :locale,
        :model_type
      )
    end

    def shop_mapping_params
      params.require(:shop_mapping).permit(
        :id,
        :country_id,
        :url_home,
      )
    end
  end
end
