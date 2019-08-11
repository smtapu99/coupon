class InactivateAffiliateNetworks < ActiveRecord::Migration[5.2]
  def up
    AffiliateNetwork.where(id: %w(12 42 54 55 56 58 80 81 35 123 83)).update_all(status: AffiliateNetwork.statuses[:blocked])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
