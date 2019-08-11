class AddKeypunchToVotes < ActiveRecord::Migration[5.0]
  def change
    add_column :votes, :keypunch, :string
    add_index  :votes, :keypunch
  end
end
