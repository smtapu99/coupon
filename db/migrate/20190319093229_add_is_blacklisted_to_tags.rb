class AddIsBlacklistedToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :is_blacklisted, :boolean, default: false, null: false, index: true

    add_index :tags, [:word, :country_id, :is_blacklisted]
  end
end
