class AddSiteIdToProblems < ActiveRecord::Migration[5.0]
  def change
    add_column :problems, :site_id, :integer, default: 0, null: false, index:true
    remove_column :problems, :user_id
  end
end
