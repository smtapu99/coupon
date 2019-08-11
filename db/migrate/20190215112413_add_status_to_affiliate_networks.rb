class AddStatusToAffiliateNetworks < ActiveRecord::Migration[5.2]
  def change
    add_column :affiliate_networks, :status, :string, default: 'active', null: false
  end
end
