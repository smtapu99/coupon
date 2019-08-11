class RemoveVotesFromCinesaInAbc < ActiveRecord::Migration[5.0]
  def self.up
    # shop cinesa on abc
    shop = Shop.find_by(id: 13463, site_id: 31)

    if shop.present?
      Vote.where(shop_id: shop.id).destroy_all
      shop.update(total_votes: 0, total_stars: 0)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
