class ExpiredExclusive
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :coupon_ids, :status, :end_date

  validates_presence_of :end_date

  validate :end_date_valid
  validate :coupons_valid

  def solve
    return false unless coupons.present?
    coupons.update(changed_params)
  end

  private

  def coupons_valid
    coupons.each do |coupon|
      coupon.assign_attributes(changed_params)
      coupon.errors.full_messages.each do |message|
        errors.add :coupon, "ID #{coupon.id}: #{message}"
      end unless coupon.valid?
    end
  end

  def end_date_valid
    errors.add :end_date, 'needs to be greater then today' if end_date.present? && end_date.to_date <= Time.zone.now.to_date
  end

  def changed_params
    {
      status: status,
      end_date: sanitized_end_date
    }.delete_if { |k, v| v.nil? }
  end

  def sanitized_end_date
    return nil if end_date.blank?
    "#{end_date} 23:59:59".to_time
  end

  def coupons
    @coupons ||= Coupon.where(id: coupon_ids)
  end
end
