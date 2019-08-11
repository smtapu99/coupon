class UserCountry < ApplicationRecord
  belongs_to :user
  belongs_to :country

  def self.cached_current_user_countries_id
    Rails.cache.fetch([name, 'current_user_countries_id']) do
      where(user_id: User.current.id).group(:country_id)
    end
  end
end
