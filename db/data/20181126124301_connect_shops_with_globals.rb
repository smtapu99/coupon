class ConnectShopsWithGlobals < ActiveRecord::Migration[5.2]
  def up
    path = Rails.root.join('files/global_shops.csv')
    csv = Roo::CSV.new(path, csv_options: { col_sep: ';' })
    globals = {}
    errors = []
    csv.drop(1).each do |row|
      (globals[row[1].chomp] ||= []) << row[0]
    end

    Global.where(model_type: 'Shop').delete_all
    globals.each do |set|
      begin
        Shop.where(id: set[1]).update(global: Global.create(name: set[0], model_type: 'Shop'))
      rescue Exception => e
        errors << [set, e]
      end
    end

    p errors.inspect if errors.present?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
