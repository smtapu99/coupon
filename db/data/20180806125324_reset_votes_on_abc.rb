class ResetVotesOnAbc < ActiveRecord::Migration[5.2]
  def up
    slugs = [
      'cupon-aliexpress',
      'codigo-promocional-edreams',
      'codigo-promocional-amazon',
      'codigo-descuento-vueling',
      'codigo-descuento-ebay',
      'foreo',
      'descuento-just-eat'
    ]
    shops = Shop.where(site_id: 31, slug: slugs)
    raise 'shop missing' if slugs.count != shops.count

    shops.each do |shop|
      Vote.where(shop_id: shop.id).destroy_all
      shop.update(total_votes: 0, total_stars: 0)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
