class AddColumBanners < ActiveRecord::Migration[5.2]
  def change
  	add_column :banners, :show_on_home_page, :boolean, default: false, null: false
  	add_column :banners, :excluded_for_mobile_resolution, :boolean, default: false, null: false
  end
end
