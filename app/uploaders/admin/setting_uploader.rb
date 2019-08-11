class Admin::SettingUploader < Admin::BaseUploader
  def self.store_dir record, name
    @@model_setting = record
    @@current_name  = name
    store_dir_template
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    self.class.store_dir_template
  end

  def self.store_dir_template
    "#{@@model_setting.class.to_s.underscore}/#{@@model_setting.id || 1}/#{@@current_name}"
  end

  def set_setting setting
    @@model_setting = setting
  end

  def set_current_name name
    @@current_name = name
  end

  process :kraken_optimize
  process :resize_to_limit => [1900, 0]

  version :thumb do
    resize_to_fill(150, 150)
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    ['ico'] + super
  end

end