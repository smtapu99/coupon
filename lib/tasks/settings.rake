namespace :settings do
  task :remove_field, [:setting_id, :field] => :environment do |t, args|
    setting = Setting.find(args[:setting_id])
    Setting.remove_field(args[:setting_id], args[:field])
  end
end
