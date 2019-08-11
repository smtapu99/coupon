class AddCurrencyToCoupons < ActiveRecord::Migration[5.2]
  def change
    add_column :coupons, :currency, :string, after: :savings_in
  end
end
