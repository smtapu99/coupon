class CouponTag < ApplicationRecord

  belongs_to :tag
  belongs_to :coupon

  validates_uniqueness_of :tag_id, scope: [:coupon_id], message: "is duplicate"
end
