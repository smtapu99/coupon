class RemovePersonalizedFieldsFromVotesAndTrackingUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :votes, :ip, :string
    remove_column :votes, :user_agent, :string
    remove_column :tracking_users, :email, :string
    remove_column :tracking_users, :ip, :string
  end
end
