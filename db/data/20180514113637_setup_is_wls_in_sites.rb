class SetupIsWlsInSites < ActiveRecord::Migration[5.0]
  def self.up
    Site.where.not(hostname: [
      'cupon.es',
      'cupom.com',
      'cupon.cl',
      'cupon.com.co',
      'indirimkuponu.com',
      'sconti.com',
      'skidkakupony.ru',
      'tuscupones.com.mx',
      'kupon.pl',
      'www.rebatly.es',
      'www.rebatly.com.br',
      'www.rebatly.it',
      'www.promokodabra.ru',
      'dealies.co.uk'
    ]).update_all(is_wls: true)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
