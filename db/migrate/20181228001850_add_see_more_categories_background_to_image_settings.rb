class AddSeeMoreCategoriesBackgroundToImageSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :image_settings, :see_more_categories_background, :string
  end
end
