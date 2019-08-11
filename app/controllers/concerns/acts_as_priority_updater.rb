module ActsAsPriorityUpdater
  extend ActiveSupport::Concern

  included do
    after_action :update_priorities, only: [:update]
  end

  def update_priority_for record
    case true
    when record.is_a?(Coupon)
      record.calculate_priority
      record.shop.calculate_priority
    when record.is_a?(Shop)
      record.calculate_priority
      record.coupons.each(&:calculate_priority)
    end
  end

  def update_priorities

    case true
    when @coupon.present?
      @coupon.calculate_priority
      @coupon.shop.calculate_priority if @coupon.shop.present?
    when @shop.present?
      @shop.calculate_priority
      @shop.coupons.each(&:calculate_priority)
    end
  end

end
