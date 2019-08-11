class CouponCategory < ApplicationRecord
  include ClearsCustomCaches


  belongs_to :coupon, validate: false
  belongs_to :category, validate: false

  # validates_presence_of :category_id
  # validates_uniqueness_of :category_id, scope: :coupon_id
end
