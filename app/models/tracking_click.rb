class TrackingClick < ApplicationRecord
  include ActsAsSiteable
  include TruncateReferrer

  has_one :campaign_tracking_data, dependent: :destroy
  belongs_to :tracking_user
  belongs_to :coupon

  accepts_nested_attributes_for :campaign_tracking_data

  scope :click_out, -> { where(click_type: 'click_out') }
  scope :click_in, -> { where(click_type: 'click_in') }
  scope :with_uniqid, -> { where('uniqid is not null') }

  # # used for migration with zero downtime.
  # # disables writes to the rejected colums
  def self.columns
    super.reject do |column|
      [
        'page_type'
      ].include?(column.name.to_s)
    end
  end
end
