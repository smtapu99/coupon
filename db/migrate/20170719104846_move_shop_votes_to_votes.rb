class MoveShopVotesToVotes < ActiveRecord::Migration[5.0]
  def change
    add_column :shop_votes, :stars, :integer, default: 0, null: false

    execute "Update shop_votes inner join votes on shop_votes.vote_id = votes.id set shop_votes.stars = votes.votes"

    remove_column :shop_votes, :vote_id, :integer
    drop_table    :votes
    rename_table  :shop_votes, :votes
    add_index     :votes, [:id, :shop_id, :ip, :user_agent]
  end
end
