class CreateCampaignCoupons < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns_coupons do |t|
      t.belongs_to :campaign
      t.belongs_to :coupon
    end
  end
end
