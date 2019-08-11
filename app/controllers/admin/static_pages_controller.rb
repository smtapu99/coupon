require 'vue_data/static_page'

module Admin
  class StaticPagesController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    # before_action :set_static_page, only: [:show, :edit, :update, :destroy]
    before_action :set_static_page, only: [:edit, :update]

    # GET /admin/static_pages
    # GET /admin/static_pages.json
    def index
      respond_to do |format|
        format.json { render json: VueData::StaticPage.render_json(Site.current, params), status: :ok }
        format.html
      end
    end

    # GET /admin/static_pages/new
    def new
      @static_page = StaticPage.new
    end

    # GET /admin/static_pages/1/edit
    def edit
    end

    # POST /admin/static_pages
    # POST /admin/static_pages.json
    def create
      @static_page = StaticPage.new(static_page_params)

      respond_to do |format|
        if @static_page.save
          format.html { redirect_to admin_static_pages_url, notice: 'Static page was successfully created.' }
          format.json { render action: 'show', status: :created, location: @static_page }
        else
          format.html { render action: 'new' }
          format.json { render json: @static_page.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/static_pages/1
    # PATCH/PUT /admin/static_pages/1.json
    def update
      respond_to do |format|
        if @static_page.update(static_page_params)
          format.html { redirect_to admin_static_pages_url, notice: 'Static page was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @static_page.errors, status: :unprocessable_entity }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_static_page
        @static_page = StaticPage.find_by(id: params[:id], site_id: Site.current.id) || not_found
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def static_page_params
        params.require(:static_page).permit(:title, :slug,
          :status, :header_color, :header_icon, :css_class, :display_sidebar,
          html_document_attributes: [
            :meta_robots, :meta_keywords, :meta_description, :meta_title, :content,
            :welcome_text, :h1, :h2, :htmlable_id, :htmlable_type, :head_scripts
          ])
      end
  end
end
