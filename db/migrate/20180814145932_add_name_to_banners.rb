class AddNameToBanners < ActiveRecord::Migration[5.2]
  def change
    add_column :banners, :name, :string, after: :id
  end
end
