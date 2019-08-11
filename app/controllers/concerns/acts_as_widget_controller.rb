module ActsAsWidgetController
  extend ActiveSupport::Concern

  included do

    before_action :check_presence_of_campaign, only: [:new, :edit, :index, :destroy]

    # checks if the current changes are to be done for a special campaign
    def check_presence_of_campaign
      # either campaign is set in params
      if params.has_key? :campaign
        Campaign.current = Campaign.where(id: params[:campaign]).first
        if Campaign.current.blank?
          redirect_to admin_widgets_url, notice: "Please select a valid campaign"
        end

      # or campaign is already assigned to the current widget
      elsif @widget.present? and @widget.campaign_id.present?
        Campaign.current = Campaign.find(@widget.campaign_id)

      # else work without a current campaign
      else
        Campaign.current = nil
      end

      @campaign_id = Campaign.current ? Campaign.current.id : nil
    end
  end
end
