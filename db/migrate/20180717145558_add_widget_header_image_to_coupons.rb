class AddWidgetHeaderImageToCoupons < ActiveRecord::Migration[5.0]
  def change
    add_column :coupons, :widget_header_image, :string, after: :logo
  end
end
