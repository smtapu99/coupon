class BlockShopsAndCouponsOfInactiveSites < ActiveRecord::Migration[5.2]
  def up
    inactive_sites = Site.where(status: 'inactive')
    inactive_sites.each do |site|
      site.shops.update_all status: 'blocked'
      site.coupons.update_all status: 'blocked'
    end if inactive_sites.present?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
