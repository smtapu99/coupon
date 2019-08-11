class Admin::ShopUploader < Admin::BaseUploader
  process :resize_to_limit => [1170, 0]
  process :kraken_optimize

  version '_0x120', if: :header_image? do
    process :resize_to_fit => [0, 120]
  end

  version '_0x120', if: :first_coupon_image? do
    process :resize_to_fit => [0, 120]
  end

  version '_40x40', if: :logo? do
    process :resize_to_fit => [40, 40]
  end

  version '_110x110', if: :logo? do
    process :resize_to_fit => [110, 110]
  end

  version '_180x180', if: :logo? do
    process :resize_to_fit => [180, 180]
  end

  version '_200x200', if: :logo? do
    process :resize_to_fit => [200, 200]
  end

  version :large do
    process :resize_large_by_name
  end

  version :thumb do
    process :resize_thumb_by_name
  end

  version :standard do
    process :resize_by_name
  end

  def default_url(*args)
    if mounted_as == :logo
      return '/assets/shop_logo_default.png' if Rails.env.test?
      ActionController::Base.helpers.asset_url("shop_logo_default.png")
    end
  end

  def logo? file
    mounted_as == :logo
  end

  def header_image? file
    mounted_as == :header_image
  end

  def first_coupon_image? file
    mounted_as == :first_coupon_image
  end

  def resize_large_by_name
    if mounted_as == 'header_image'.to_sym
      resize_to_limit(748, 748)
    else
      resize_to_limit(600, 600)
    end
  end

  def resize_thumb_by_name
    if mounted_as == 'logo'.to_sym
      if ENV['RAKE_IMAGE_COPY'].nil?
        resize_to_fill(150, 150)
      else
        resize_to_fit(150, 100000) # allows a different height than 150px for imported images
      end
    end

    resize_to_fill(375, 100) if mounted_as == 'header_image'.to_sym
    resize_to_fill(375, 100) if mounted_as == 'first_coupon_image'.to_sym
  end

  def resize_by_name
    if mounted_as == 'logo'.to_sym
      if ENV['RAKE_IMAGE_COPY'].nil?
        resize_to_fill(150, 150)
      else
        resize_to_fit(150, 100000) # allows a different height than 150px for imported images
      end
    end

    resize_to_fill(1170, 310) if mounted_as == 'header_image'.to_sym
    resize_to_fill(1170, 310) if mounted_as == 'first_coupon_image'.to_sym
  end
end
