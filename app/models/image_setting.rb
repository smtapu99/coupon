class ImageSetting < ApplicationRecord
  include ActsAsFaviconGenerator

  belongs_to :site

  mount_uploader :favicon, Admin::ImageUploader
  mount_uploader :logo, Admin::ImageUploader
  mount_uploader :hero, Admin::ImageUploader
  mount_uploader :see_more_categories_background, Admin::ImageUploader
end
