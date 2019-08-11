Fog::Mock.reset
Fog.mock!

fog_config = Rails.application.config.custom_services

Fog::Storage.new(
  provider: fog_config['provider'],
  google_storage_access_key_id: fog_config['google_storage_access_key_id'],
  google_storage_secret_access_key: fog_config['google_storage_secret_access_key']
).tap do |connection|
  connection.directories.create(key: fog_config['fog_directory'])
end
