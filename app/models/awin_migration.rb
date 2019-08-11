class AwinMigration
  include ActiveModel::Model

  ZANOX_ID = 11
  AWIN_ID = 115

  attr_accessor(
    :shop_id,
    :clickout_url,
    :change_to_awin,
    :run
  )

  validates :shop_id, presence: true
  validates :clickout_url, url: true, presence: true

  def shop
    Shop.find(shop_id)
  end

  def migrate
    if change_to_awin.to_i == 1
      coupons_count = active_zanox_coupons.update_all(url: clickout_url, affiliate_network_id: AWIN_ID)
      shop.update(fallback_url: clickout_url, prefered_affiliate_network_id: AWIN_ID)
    else
      coupons_count = active_zanox_coupons.update_all(url: clickout_url)
      shop.update(fallback_url: clickout_url)
    end
    return true, "You updated #{coupons_count} coupons and changed the fallback_url of #{shop.title} to #{clickout_url}"
  rescue StandardError
    return false, 'An Error occured during the process'
  end

  def active_zanox_coupons
    Site.current.coupons
                .where(shop_id: shop_id, affiliate_network_id: ZANOX_ID)
                .where('coupons.end_date > ?', Time.zone.now)
                .where('coupons.status = ?', 'active')
  end

  def count_active_zanox_coupons
    active_zanox_coupons.count
  end
end
