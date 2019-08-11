class RemoveFieldsFromSettings < ActiveRecord::Migration[5.0]
  def up
    Setting.all.each do |setting|
      puts 'updating setting' + setting.id.to_s
      begin
        Setting.remove_field(setting.id, 'style.background_image')
        Setting.remove_field(setting.id, 'style.background_repeat')
        Setting.remove_field(setting.id, 'style.background_size')
        Setting.remove_field(setting.id, 'style.background_position')
        Setting.remove_field(setting.id, 'image_upload.background_image_url')
      rescue Exception => e
        next
      end
    end
  end

  def down
    # unable to revert change
  end
end
