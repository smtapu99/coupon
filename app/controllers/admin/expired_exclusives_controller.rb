require 'vue_data/quality/expired_exclusive'

module Admin
  class ExpiredExclusivesController < QualityController

    before_action :authorize_write_access, only: [:edit, :update]

    def index
      @title = 'Expired Exclusive Coupons'
      respond_to do |format|
        format.html { render :index }
        format.json { render json: ::VueData::Quality::ExpiredExclusive.render_json(Site.current.id, params), status: :ok }
      end
    end

    def edit
      @expired_exclusive = ExpiredExclusive.new

      @expired_exclusive.coupon_ids = [*params[:id]] if params[:id].present?
      @expired_exclusive.coupon_ids = params[:ids] if params[:ids].present?

      respond_to do |format|
        format.html { render partial: 'admin/quality/expired_exclusive/form' }
        format.js { render layout: false }
      end
    end

    def update
      Time.zone = Site.current.time_zone
      @expired_exclusive = ExpiredExclusive.new(expired_exclusive_params)

      respond_to do |format|
        if @expired_exclusive.valid? && @expired_exclusive.solve
          @success = true
          flash[:notice] = 'Status and end date were applied to all affected coupons'
          format.html { render partial: 'admin/quality/expired_exclusive/form' }
        else
          format.html { render partial: 'admin/quality/expired_exclusive/form' }
        end
      end
    end

    private

    def authorize_write_access
      authorize! :manage, Coupon
    end

    def expired_exclusive_params
      params.require(:expired_exclusive).permit(
        :status,
        :end_date,
        coupon_ids: []
      )
    end
  end
end
