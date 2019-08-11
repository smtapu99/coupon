class RemoveUnusedFieldsFromNewsletterWidget < ActiveRecord::Migration[5.0]
  def change
    ['badge_color', 'currency', 'headline', 'text'].each do |field|
      Widget.remove_field_from_widget('newsletter', field)
    end
  end
end
