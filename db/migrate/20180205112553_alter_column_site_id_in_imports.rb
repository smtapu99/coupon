class AlterColumnSiteIdInImports < ActiveRecord::Migration[5.0]
  def change
    # to be able to savely remove the site_id from coupon_imports we first have to make it nullable. otherwise sql complains
    change_column :coupon_imports, :site_id, :integer, null: true
  end
end
