class Admin::MediaUploader < Admin::BaseUploader
  process :resize_to_limit => [1900, 0]
  process :kraken_optimize

  version :thumb do
    resize_to_fill(150, 150)
  end
end
