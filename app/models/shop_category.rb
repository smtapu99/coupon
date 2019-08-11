class ShopCategory < ApplicationRecord
  include ClearsCustomCaches

  belongs_to :shop, validate: false
  belongs_to :category, validate: false

  validate :site_id_matching

private

  def site_id_matching
    self.errors.add :category, "id #{category_id} cannot get assigned to shop #{shop_id} because they are from different sites" if self.category.site_id != self.shop.site_id
  end

end
