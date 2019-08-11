require 'vue_data/affiliate_network'

module Admin
  class AffiliateNetworksController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_affiliate_network, only: [:edit, :update]

    # GET /admin/affiliate_networks
    # GET /admin/affiliate_networks.json
    def index
      respond_to do |format|
        format.json { render json: VueData::AffiliateNetwork.render_json(AffiliateNetwork, params), status: :ok }
        format.html
      end
    end

    # GET /admin/affiliate_networks/new
    def new
      @affiliate_network = AffiliateNetwork.new
    end

    # GET /admin/affiliate_networks/1/edit
    def edit
    end

    # POST /admin/affiliate_networks
    # POST /admin/affiliate_networks.json
    def create
      @affiliate_network = AffiliateNetwork.new(affiliate_network_params)

      respond_to do |format|
        if @affiliate_network.save
          format.html { redirect_to admin_affiliate_networks_url, notice: 'Affiliate network was successfully created.' }
          format.json { render action: 'show', status: :created, location: admin_affiliate_networks_url }
        else
          format.html { render action: 'new' }
          format.json { render json: @affiliate_network.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/affiliate_networks/1
    # PATCH/PUT /admin/affiliate_networks/1.json
    def update
      respond_to do |format|
        if @affiliate_network.update(affiliate_network_params)
          format.html { redirect_to admin_affiliate_networks_url, notice: 'Affiliate network was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @affiliate_network.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_affiliate_network
      @affiliate_network = AffiliateNetwork.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def affiliate_network_params
      params.require(:affiliate_network).permit(:name, :slug, :status, :validate_subid, :validation_regex)
    end
  end
end
