class AddValidationRegexToAffiliateNetworks < ActiveRecord::Migration[5.2]
  def change
    add_column :affiliate_networks, :validation_regex, :string, after: :validate_subid
  end
end
