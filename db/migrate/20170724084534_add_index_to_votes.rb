class AddIndexToVotes < ActiveRecord::Migration[5.0]
  def change
    add_index :votes, [:id, :shop_id]
  end
end
