require 'vue_data/csv_export'

module Admin
  class CsvExportsController < BaseController
    before_action :authenticate_admin_user!
    before_action :get_csv_export, only: [:edit, :destroy, :rerun]

    def index
      respond_to do |format|
        format.html
        format.json { render json: ::VueData::CsvExport.render_json(nil, params), status: :ok }
      end
    end

    def edit
    end

    def destroy
      @admin_csv_export.destroy
      respond_to do |format|
        format.json { head :ok }
      end
    end

    def rerun
      @admin_csv_export.user_id = User.current.id
      @admin_csv_export.status  = 'pending'
      @admin_csv_export.remove_file!

      respond_to do |format|
        if @admin_csv_export.save
          Resque.enqueue(CsvExportWorker, @admin_csv_export.id)
          format.html { redirect_to admin_csv_exports_path, notice: 'File is beeing processed again' }
        else
          @admin_csv_export.update_attribute(:status, 'error')
          @admin_csv_export.update_attribute(:error_messages, @admin_csv_export.errors.full_messages)
          redirect_to 'index', notice: 'Error while processing the requested file'
        end
      end
    end

  private

    def get_csv_export
      @admin_csv_export = CsvExport.find(params[:id])
    end

  end
end
