class Admin::CouponUploader < Admin::BaseUploader
  include Carrierwave::ActsAsClearTmpFiles

  process :resize_to_limit => [1170, 0]
  process :kraken_optimize

  version :large do
    resize_to_limit(600, 600)
  end

  version :thumb do
    process :resize_thumb_by_name
  end

  version '_110x110', if: :logo? do
    process :resize_to_fit => [110, 110]
  end

  version '_0x120', if: :widget_header_image? do
    process :resize_to_fit => [0, 120]
  end

  version :standard do
    process :resize_by_name
  end

  def resize_thumb_by_name
    if mounted_as == 'logo'.to_sym
      if ENV['RAKE_IMAGE_COPY'].nil?
        resize_to_fill(70, 70)
      else
        resize_to_fit(70, 100000) # allows a different height than 150px for imported images
      end
    end
  end

  def resize_by_name
    if mounted_as == 'logo'.to_sym
      if ENV['RAKE_IMAGE_COPY'].nil?
        resize_to_fill(150, 150)
      else
        resize_to_fit(150, 100000) # allows a different height than 150px for imported images
      end
    end
  end

  def logo?(file)
    mounted_as == :logo
  end

  def widget_header_image?(file)
    mounted_as == :widget_header_image
  end

  # necessary to overwrite due to usage of ImportedCoupon
  def store_dir
    "coupon/#{model.id}/#{mounted_as}"
  end
end
