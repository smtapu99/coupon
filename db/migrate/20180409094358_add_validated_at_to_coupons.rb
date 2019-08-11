class AddValidatedAtToCoupons < ActiveRecord::Migration[5.0]
  def change
    add_column :coupons, :validated_at, :datetime, after: :end_date
  end
end
