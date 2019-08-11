class CouponCode < ApplicationRecord
  include ActsAsExportable
  include ActsAsSiteable

  attr_reader :end_date_from, :end_date_to, :created_at_from, :created_at_to, :used_at_from, :used_at_to

  belongs_to :coupon
  belongs_to :tracking_user

  validate :site_id_correct
  validates :coupon, presence: true
  validates_presence_of :site_id, :code

  scope :imported, -> { where(is_imported: true) }
  scope :usable, -> { where(is_imported: false, used_at: nil).where('coupon_codes.end_date is null or coupon_codes.end_date >= ?', Time.zone.now) }

  def self.next_usable
    usable.limit(1).first
  end

  def self.grid_filter(params)
    query = self
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where(coupon_id: params[:coupon_id]) if params[:coupon_id].present?
    query = query.where('code like ?', "%#{params[:code]}%") if params[:code].present?
    query = query.where(tracking_user_id: params[:tracking_user_id]) if params[:tracking_user_id].present?
    query = query.where(is_imported: params[:is_imported].to_s == 'true') if params[:is_imported].present?

    query = query.where('end_date >= ?',  string_to_utc_time('end_date_from', params['end_date_from'])) if params['end_date_from'].present?
    query = query.where('end_date <= ?', string_to_utc_time('end_date_to', params['end_date_to'])) if params['end_date_to'].present?
    query = query.where('used_at >= ?',  string_to_utc_time('used_at_from', params['used_at_from'])) if params['used_at_from'].present?
    query = query.where('used_at <= ?', string_to_utc_time('used_at_to', params['used_at_to'])) if params['used_at_to'].present?
    query = query.where('created_at >= ?',  string_to_utc_time('created_at_from', params['created_at_from'])) if params['created_at_from'].present?
    query = query.where('created_at <= ?', string_to_utc_time('created_at_to', params['created_at_to'])) if params['created_at_to'].present?
    query = query.where('updated_at >= ?',  string_to_utc_time('updated_at_from', params['updated_at_from'])) if params['updated_at_from'].present?
    query = query.where('updated_at <= ?', string_to_utc_time('updated_at_to', params['updated_at_to'])) if params['updated_at_to'].present?
    query
  end

  def self.allowed_import_params
    [:coupon_code_id, :coupon_id, :code, :end_date]
  end

  def self.export(params)
    query = where(site_id: Site.current.id)
    query = query.where(coupon_id: params[:coupon_id])                if params[:coupon_id].present?
    query = query.where(is_imported: params[:is_imported])            if params[:is_imported].present?
    query = query.where(tracking_user_id: params[:tracking_user_id])  if params[:tracking_user_id].present?

    query = query.where('coupon_codes.used_at >= ?', concat_datetime('used_at_from', params)) if params['used_at_from(1i)'].present?
    query = query.where('coupon_codes.used_at <= ?', concat_datetime('used_at_to', params)) if params['used_at_to(1i)'].present?

    query = query.where('coupon_codes.end_date >= ?', concat_datetime('end_date_from', params)) if params['end_date_from(1i)'].present?
    query = query.where('coupon_codes.end_date <= ?', concat_datetime('end_date_to', params)) if params['end_date_to(1i)'].present?

    query = query.where('coupon_codes.created_at >= ?', concat_datetime('created_at_from', params)) if params['created_at_from(1i)'].present?
    query = query.where('coupon_codes.created_at <= ?', concat_datetime('created_at_to', params)) if params['created_at_to(1i)'].present?

    query
  end

  def use!
    self.used_at = Time.zone.now
    save
  end

  private

  def site_id_correct
    if coupon.present? && site_id != coupon.site_id && !site_id.nil?
      errors.add(:coupon_id, 'is invalid; You are not allowed to access this coupon')
    end
  end
end
