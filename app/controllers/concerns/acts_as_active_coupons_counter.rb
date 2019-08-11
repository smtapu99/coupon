module ActsAsActiveCouponsCounter
  extend ActiveSupport::Concern

  included do
    after_action :update_active_coupons_table, only: [:update]
  end

  def update_active_coupons_count_for record

    case true
    when record.is_a?(Coupon)
      record.update_associated_active_coupons_counts
    when record.is_a?(Shop)
      record.update_active_coupons_count
    when record.is_a?(Category)
      record.update_active_coupons_count
    end

  end

  def update_active_coupons_table

    case true
    when @coupon.present?
      @coupon.update_associated_active_coupons_counts
    when @shop.present?
      @shop.update_active_coupons_count
    when @category.present?
      @category.update_active_coupons_count
    end

  end

end
