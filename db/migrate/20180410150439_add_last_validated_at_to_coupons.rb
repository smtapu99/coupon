class AddLastValidatedAtToCoupons < ActiveRecord::Migration[5.0]
  def change
    add_column :coupons, :last_validation_at, :datetime, after: :end_date
  end
end
