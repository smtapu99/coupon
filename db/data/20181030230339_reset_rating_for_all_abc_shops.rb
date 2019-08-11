class ResetRatingForAllAbcShops < ActiveRecord::Migration[5.2]
  def up
    site = Site.find 31
    if site.present?
      shops = site.shops.active.select { |shop| shop.rating != 0 && shop.rating < 2 }
      shops.each do |shop|
        Vote.where(shop_id: shop.id).destroy_all
        shop.update(total_votes: 0, total_stars: 0)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
