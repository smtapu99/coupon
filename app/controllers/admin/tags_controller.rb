require 'vue_data/tag'

module Admin
  class TagsController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    before_action :set_tag, only: [:edit, :update]

    # GET /admin/tags
    # GET /admin/tags.json
    def index
      respond_to do |format|
        format.json { render json: VueData::Tag.render_json(Site.current.id, params), status: :ok }
        format.html
      end
    end

    # GET /admin/tags/new
    def new
      @tag = Tag.new
    end

    # GET /admin/tags/1/edit
    def edit
    end

    # POST /admin/tags
    # POST /admin/tags.json
    def create
      @tag = Tag.new(tag_params)
      @tag.site_id = Site.current.id

      respond_to do |format|
        if @tag.save
          format.html { redirect_to admin_tags_url, notice: 'Tag was successfully created.' }
          format.json { render action: 'show', status: :created, location: @tag }
        else
          format.html { render action: 'new' }
          format.json { render json: @tag.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/tags/1
    # PATCH/PUT /admin/tags/1.json
    def update
      respond_to do |format|
        if @tag.update(tag_params)
          format.html { redirect_to admin_tags_url, notice: 'Tag was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @tag.errors, status: :unprocessable_entity }
        end
      end
    end

    def export_modal
      @tag = Tag.new
      respond_to do |format|
        format.js
      end
    end

    def export
      csv_export = CsvExport.new(export_type: 'Tag', params: (params[:tag] ||= {}).merge(site_id: Site.current.id))
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

    def import_template
      @tags = Tag.where('1=0')
      headers["Content-Disposition"] = "attachment; filename=\"#{"tags_import_template_#{Time.zone.now.to_date}.xlsx"}\""
      render 'export', formats: :xlsx, layout: false
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find_by(id: params[:id], site_id: Site.current.id) || not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(
        :word,
        :site_id,
        :is_blacklisted,
        :category_id
      )
    end
  end
end
