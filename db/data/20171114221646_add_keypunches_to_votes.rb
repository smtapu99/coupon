class AddKeypunchesToVotes < ActiveRecord::Migration[5.0]
  def self.up
    execute("UPDATE votes SET keypunch = SHA1(CONCAT(votes.shop_id, '-', votes.ip, '-', votes.user_agent))");
  end
  def self.down
    # Not implemented
  end
end
