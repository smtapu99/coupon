# This model is used to save the timestamp of the latest route update.
# This value will then be compared with a value that we save into the
# Thread.current if the value in Thread.current is different then we will
# run DynamicRoutes.reload
#
# check app/middleware/routes_reloader.rb
class RoutesChangedTimestamp
  def self.update_timestamp(site)
    ts = Time.zone.now.to_i
    Rails.cache.write("#{site.hostname}_rcts", ts, expires_in: 1.hour)
  end
end
