class CampaignsCoupon < ApplicationRecord
  belongs_to :campaign
  belongs_to :coupon
end
