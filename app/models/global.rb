class Global < ApplicationRecord
  include ActsAsExportable

  enum model_type: { Shop: 'Shop' }

  validates :name, uniqueness: { scope: :model_type }, presence: true
  validates :model_type, presence: true

  scope :shops, -> { where(model_type: 'Shop') }

  has_many :global_shop_mappings, class_name: 'Global::ShopMapping'

  def self.grid_filter(params)
    query = all
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(model_type: params[:model_type]) if params[:model_type].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query
  end

  def self.export(params)
    query = self
    query = query.all
    query
  end

  def self.to_export_xls
    xls = Axlsx::Package.new
    xls.workbook do |wb|
      wb.add_worksheet(name: "globals_#{Time.now.to_date}") do |sheet|
        sheet.add_row Global::CSV_EXPORT_COLUMN_HEADERS[:global].values

        all.each do |global|
          sheet.add_row global.csv_mapped_attributes
        end
      end
    end
    xls
  end
end
