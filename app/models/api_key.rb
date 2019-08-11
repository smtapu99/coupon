# This is how we grant access to the API.
# User logs in via the API. Access_token is granted and returned to them.
# On subsequent logins they use the access_token rather than their credentials.
class ApiKey < ApplicationRecord
  before_create :generate_access_token
  before_create :set_expiration, unless: -> { site.present? } # site tokens never expire
  belongs_to :user
  belongs_to :site

  def expired?
    return false if expires_at.nil?
    Time.zone.now >= expires_at
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def set_expiration
    self.expires_at = Time.zone.now + (3 * 60 * 60)
  end
end
