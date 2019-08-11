require 'vue_data/country'

module Admin
  class CountriesController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_country, only: [:edit, :update]

    # GET /admin/countries
    # GET /admin/countries.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Country.render_json(nil, params), status: :ok }
        format.html
      end
    end

    # GET /admin/countries/new
    def new
      @country = Country.new
    end

    # GET /admin/countries/1/edit
    def edit
    end

    # POST /admin/countries
    # POST /admin/countries.json
    def create
      @country = Country.new(country_params)

      respond_to do |format|
        if @country.save
          format.html { redirect_to admin_countries_url, notice: 'Country was successfully created.' }
          format.json { render action: 'show', status: :created, location: @country }
        else
          format.html { render action: 'new' }
          format.json { render json: @country.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/countries/1
    # PATCH/PUT /admin/countries/1.json
    def update
      respond_to do |format|
        if @country.update(country_params)
          format.html { redirect_to admin_countries_url, notice: 'Country was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @country.errors, status: :unprocessable_entity }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_country
        # @country = Country.find(params[:id])
        @country = Country.find(params[:id]) || not_found
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def country_params
        params.require(:country).permit(:name, :locale)
      end
  end
end
