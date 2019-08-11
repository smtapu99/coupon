require 'vue_data/medium'

module Admin
  class MediaController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    # before_action :set_media, only: [:show, :edit, :update, :destroy]
    before_action :set_media, only: [:edit, :update]
    before_action :set_site, only: [:index, :create]

    # GET /admin/medias
    # GET /admin/medias.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Medium.render_json(Site.current.id, params), status: :ok }
        format.html
      end

      @new_media = Medium.new
    end

    # GET /admin/medias/new
    def new
      @media = Medium.new
    end

    # GET /admin/medias/1/edit
    def edit
    end

    # POST /admin/medias
    # POST /admin/medias.json
    def create
      files_to_upload = media_params
      file_errors = []
      file_success = []

      files_to_upload.each do |media_file|

        mu = Medium.new
        mu.file_name = media_file
        mu.site_id = @site_id

        if mu.save
          file_success << File.basename(mu.file_name.to_s)
        else
         file_errors << File.basename(mu.errors.to_s)
        end
      end


      respond_to do |format|
        unless file_success.blank?
          format.html { redirect_to admin_media_url + "?site_id=#{@site_id}", notice: 'Success! Uploaded the following files: ' +  file_success.join(", ")}
        else
          format.html { redirect_to admin_media_url+ "?site_id=#{@site_id}", flash: {:error => 'Upload failed for the following files' + file_errors.join(", ")}}
        end
      end
    end

    def update
    end

    private

      def set_site
        if Site.current
          @site_id = Site.current.id
        elsif params[:site_id]
          @site_id = params[:site_id]
        else
          @site_id = User.current.sites.first.id
        end
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_media
        @media = Medium.find_by(id: params[:id], site_id: Site.current.id) || not_found
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def media_params
          params.require(:file_names)
      end
  end
end
