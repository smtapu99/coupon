class CampaignTrackingData < ApplicationRecord
  belongs_to :tracking_click

  serialize :data, JSON

  validates_presence_of :data, :tracking_click
end
