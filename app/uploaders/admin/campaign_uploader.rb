class Admin::CampaignUploader < Admin::BaseUploader
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{@@model_setting_campaign.class.to_s.underscore}/#{@@model_setting_campaign.id}/#{@@current_name_campaign}"
  end

  process :resize_to_limit => [1900, 0]
  process :kraken_optimize

  version :large do
    resize_to_limit(600, 600)
  end

  version :thumb do
    resize_to_limit(300, 100)
  end

  version :standard do
    resize_to_fill(752, 200)
  end

  def set_setting campaign_setting
    @@model_setting_campaign = campaign_setting
  end

  def set_current_name name
    @@current_name_campaign = name
  end
end
