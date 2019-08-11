class AlterBannerDatesToDate < ActiveRecord::Migration[5.2]
  def change
    change_column :banners, :start_date, :date
    change_column :banners, :end_date, :date
  end
end
