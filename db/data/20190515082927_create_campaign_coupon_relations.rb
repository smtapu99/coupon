class CreateCampaignCouponRelations < ActiveRecord::Migration[5.2]
  def up
    Site.active.each do |site|
      country_id = site.country_id
      active_coupons = Coupon.coupons_by_site(site.id).active.pluck(:id)
      coupon_tags = CouponTag.where(coupon_id: active_coupons).pluck(:coupon_id, :tag_id)

      site.campaigns.active.each do |campaign|
        tag = Tag.find_by(word: campaign.tag_string, country_id: country_id)
        campaign.coupon_ids = coupon_tags.select { |k| k[1] == tag.id }.map(&:first) if tag.present?
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
