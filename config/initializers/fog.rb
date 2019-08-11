if Rails.env.development? || Rails.env.test?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

# CarrierWave.configure do |config|
#   config.fog_credentials = {
#     :provider               => 'AWS',                        # required
#     :aws_access_key_id      => '     ',                        # required
#     :aws_secret_access_key  => 'yyy',                        # required
#     :region                 => 'eu-west-1',                  # optional, defaults to 'us-east-1'
#     :host                   => 's3.example.com',             # optional, defaults to nil
#     :endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
#   }
#   config.fog_directory  = 'name_of_directory'                     # required
#   config.fog_public     = false                                   # optional, defaults to true
#   config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
# end

CarrierWave.configure do |config|

  fog_config = Rails.application.config.custom_services

  config.remove_previously_stored_files_after_update = false

  config.fog_credentials = {
    provider:                         fog_config["provider"],
    google_storage_access_key_id:     fog_config["google_storage_access_key_id"],
    google_storage_secret_access_key: fog_config["google_storage_secret_access_key"]
  }
  config.fog_directory         = fog_config["fog_directory"]
  config.fog_public            = true
  config.fog_attributes        = {'Cache-Control' => 'max-age=315576000'}
  config.permissions           = 0666
  config.directory_permissions = 0777
  config.enable_processing     = true
end

# load the carrierwave processing folder including the carrierwave callbacks and more
dir = Rails.root.join('lib', 'carrierwave_processing')
$LOAD_PATH.unshift(dir)
Dir[File.join(dir, "*.rb")].each {|file| require File.basename(file) }
