class RemoveCountriesFromUsers < ActiveRecord::Migration[5.0]
  def self.up
    admin_ids = SuperUser.all.pluck(:id)
    Country.where(locale: ['en_US', 'en_UK']).each do |country|
      UserCountry.where(country: country).where('user_id not in (?)', admin_ids).destroy_all
    end
  end

  def self.down
  end
end
