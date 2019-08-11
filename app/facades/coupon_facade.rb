class CouponFacade
  attr_reader :coupon

  def initialize coupon
    raise 'Invalid coupon' unless coupon.instance_of? Coupon
    
    @coupon = coupon
  end
end
