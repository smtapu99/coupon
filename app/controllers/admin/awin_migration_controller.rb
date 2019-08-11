module Admin
  class AwinMigrationController < BaseController
    before_action :authenticate_admin_user!
    load_and_authorize_resource

    def awin
      @migration = AwinMigration.new
      @shops = Site.current.shops.active.order(title: :asc).collect { |i| [i.title_and_site_name, i.id] }
    end

    def migrate_awin
      @migration = AwinMigration.new(migration_params)

      if @migration.valid? && migration_params[:shop_id].present? && !migration_params[:run].nil?
        # step 2
        success, msg = @migration.migrate

        if success
          flash[:notice] = msg
        else
          flash[:error] = msg
        end

        redirect_to admin_awin_path and return
      elsif @migration.valid? && migration_params[:shop_id].present?
        # step 1
        @count = @migration.count_active_zanox_coupons
      end

      render :awin
    end

    private

    def migration_params
      params.require(:awin_migration).permit(
        :shop_id,
        :clickout_url,
        :change_to_awin,
        :run
      )
    end
  end
end
