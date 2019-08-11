class ChangeLocaleOfUkToGb < ActiveRecord::Migration[5.0]
  def self.up
    Country.where(locale: 'en_UK').update(locale: 'en_GB')
    Translation.where(locale: 'en_UK').update(locale: 'en_GB')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
