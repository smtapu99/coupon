class AddRatingAndTotalVotesToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :total_stars, :integer, default: 0, null: false
    add_column :shops, :total_votes, :integer, default: 0, null: false

    # TODO: comment out once applied to production
    # Rake::Task['shops:recalculate_rating'].invoke
  end
end
