class AddGlobalIdToShops < ActiveRecord::Migration[5.2]
  def change
    add_column :shops, :global_id, :integer, index: true, after: :id
  end
end
