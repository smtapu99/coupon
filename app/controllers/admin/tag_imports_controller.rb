require 'vue_data/tag_import'

module Admin
  class TagImportsController < BaseController
    before_action :authenticate_admin_user!
    before_action :set_tag_import, only: [:edit, :destroy]

    load_and_authorize_resource

    def index
      respond_to do |format|
        format.json { render json: VueData::TagImport.render_json(Site.current.id, params), status: :ok }
        format.html
      end
    end

    def edit
    end

    # POST /admin/tag_imports
    # POST /admin/tag_imports.json
    def create
      @tag_import = TagImport.new(tag_import_params)
      @tag_import.site_id = Site.current.id
      @tag_import.status  = 'pending'

      respond_to do |format|
        if @tag_import.save
          Resque.enqueue(TagImportWorker, @tag_import.id)
          format.html { redirect_to admin_tag_imports_path, notice: 'Tag Import placed into queue. Please check the status below.' }
        else
          @tag_import.update_attribute(:status, 'error')
          format.html { redirect_to new_admin_tag_import_path, error: 'An Error occurred during the file upload.' }
        end
      end
    end

    # POST /admin/tag_imports
    # POST /admin/tag_imports.json
    def create_direct
      site = Site.current

      if site.nil?
        flash[:error] = 'Please select a valid Site'
        redirect_to action: :new and return
      else
        @tag_import = TagImport.new(tag_import_params)
        @tag_import.site_id = site.id

        respond_to do |format|
          if @tag_import.save && @tag_import.run
            format.html { redirect_to admin_tag_imports_url, notice: 'Tags were successfully imported.' }
          else
            format.html { redirect_to new_admin_tag_import_path, error: 'An Error occurred during the file upload.' }
          end
        end
      end
    end

    # DELETE /admin/tag_import/1
    # DELETE /admin/tag_import/1.json
    def destroy
      @admin_tag_import.destroy
      respond_to do |format|
        format.json { head :ok }
      end
    end

    private

    def set_tag_import
      @admin_tag_import = TagImport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_import_params
      params.require(:tag_import).permit(:file)
    end
  end
end
