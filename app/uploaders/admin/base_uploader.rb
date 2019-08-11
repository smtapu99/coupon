class Admin::BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWave::PannacottaOptimizer

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  # Choose what kind of storage to use for this uploader:
  storage :fog

  asset_host 'https://' + CarrierWave::Uploader::Base.fog_directory

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  def full_cache_path
    "#{::Rails.root}/public/#{cache_dir}/#{cache_name}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
