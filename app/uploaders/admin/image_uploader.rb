class Admin::ImageUploader < Admin::BaseUploader
  process :kraken_optimize

end
