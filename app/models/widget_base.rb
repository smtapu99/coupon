# coding: utf-8
class WidgetBase < ApplicationRecord
  include ActAsEdgeCachable
  include ActsAsSiteable

  UPLOADABLE_VALUES = ['image']

  self.table_name = :widgets

  belongs_to :campaign

  serialize :value, OpenStruct

  scope :by_campaign, ->(campaign_id) { where(campaign_id: campaign_id) }
  scope :by_current_site, -> { where(site: Site.current.id) }
  scope :by_current_site_and_campaign, -> { by_site_and_campaign(Site.current, Campaign.current) }
  scope :by_site_and_campaign, ->(site, campaign) { where(site: site, campaign: campaign) }

  def widget?
    widget_type == 'widget'
  end

  def widget_area?
    widget_type == 'widget_area'
  end

  def ad_space?
    widget_type == 'ad_space'
  end

  def upload_to_bucket(uploader, file, image_column)
    uploader.set_setting self
    uploader.set_current_name image_column
    uploader.store!(file)
    uploader
  end

  def delete_from_bucket(uploader, image_column)
    uploader.set_setting self
    uploader.set_current_name image_column
    uploader.remove!
    uploader
  end

  def has_image?
    ['image'].include?(self.name)
  end

  private

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
        public
        def #{method_name}
          (self.value || {}).#{method_name}
        end
        def #{method_name}=(value)
          self.value ||= {}
          self.value.#{method_name} = value
        end
      "
    end
  end
end
