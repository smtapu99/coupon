class RemoveSiteIdFromShopImports < ActiveRecord::Migration[5.0]
  def change
    remove_column :shop_imports, :site_id, :integer
  end
end
