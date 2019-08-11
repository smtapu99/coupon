class Admin::AssetUploader < Admin::BaseUploader
  mattr_accessor :site

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def self.set_site site
    @@site = site.nil? ? Site.current : site
    asset_host = @@site.asset_hostname_for_fog
  end

  def current_site
    @@site.present? ? @@site : Site.current
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    'assets/' + current_site.host_to_file_name
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(css js)
  end

end
