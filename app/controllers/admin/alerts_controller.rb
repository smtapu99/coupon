require 'vue_data/alert'

module Admin
  class AlertsController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    def index
      respond_to do |format|
        format.html { render :index }
        format.json { render json: ::VueData::Alert.render_json(Site.current.id, params), status: :ok }
      end
    end

    def edit
      access_denied and return unless allowed_site_ids.include?(@alert.site_id)
      redirect_to @alert.edit_path
    end

    def destroy
      @alert.update(solved_by_id: User.current.id, solved_at: Time.zone.now, status: 'inactive')
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end
end
