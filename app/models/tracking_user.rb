class TrackingUser < ApplicationRecord
  include ActsAsSiteable
  include TruncateReferrer

  serialize :data, JSON  if (ENV['RAKE_IMPORT_TRACKING_FIX'].nil?)

  has_many :tracking_clicks
end
