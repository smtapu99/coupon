class RemoveSettingBackgroundAttributes < ActiveRecord::Migration[5.0]
  def self.up
    Setting.transaction do
      Setting.where('value LIKE "%image_upload%" OR value LIKE "%style%"').each do |setting|
        setting.avoid_reload_routes = true
        setting.remove_field('image_upload_background_image', false)
        setting.remove_field('image_upload_background_image_url', false)
        setting.remove_field('style_body_bg', false)
        setting.remove_field('style_background_size', false)
        setting.remove_field('style_background_repeat', false)
        setting.remove_field('style_background_position', false)
        setting.save
      end
    end
  end

  def self.down
  end
end
