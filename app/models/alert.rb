class Alert < ApplicationRecord
  enum alert_type: {
    uniq_codes_empty: 'uniq_codes_empty',
    coupons_expiring: 'coupons_expiring',
    widget_coupons_expiring_3_days: 'widget_coupons_expiring_3_days'
  }
  enum status: { active: 'active', inactive: 'inactive' }

  belongs_to :site
  belongs_to :alertable, polymorphic: true

  validates :site_id, presence: true

  def edit_path
    case alert_type.to_sym
    when :uniq_codes_empty
      "/pcadmin/coupons/#{alertable_id}/coupon_codes"
    when :widget_coupons_expiring_3_days
      "/pcadmin/widgets?campaign_id=#{alertable.campaign_id}&widget_id=#{alertable_id}"
    when :coupons_expiring
      "/pcadmin/coupons?f[shop]=#{alertable.slug}"
    end
  end

  def self.grid_filter(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)

    query = all
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where(is_critical: params[:is_critical]) if params[:is_critical].present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where(alert_type: params[:alert_type]) if params[:alert_type].present?
    query = query.where(alertable_id: params[:model_id]) if params[:model_id].present?
    query = query.where(alertable_type: params[:model]) if params[:model].present?
    query = query.where("message like ?", "%#{params[:message]}%") if params[:message].present?

    query = query.where('alerts.updated_at >= ?', string_to_utc_time('date_from', params['date_from'])) if params[:date_from].present?
    query = query.where('alerts.updated_at <= ?', string_to_utc_time('date_to', params['date_to'])) if params[:date_to].present?
    query
  end
end
