class Tag < ApplicationRecord
  include ActsAsExportable

  belongs_to :category
  belongs_to :site

  delegate :slug, to: :category, allow_nil: true, prefix: true

  validates :site_id, presence: true
  validates :word, presence: true, uniqueness: { scope: [:site_id] }

  def self.allowed_import_params
    [
      'Tag ID',
      'Word',
      'Category Slug',
      'Is Blacklisted'
    ]
  end

  def self.grid_filter(params)
    query = self.all
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('word like ?', "%#{params[:word]}%") if params[:word].present?
    query = query.where(is_blacklisted: params[:is_blacklisted].to_s == 'yes') if params[:is_blacklisted].present?
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where(category_id: params[:category]) if params[:category].present?

    query
  end

  def self.to_export_xls
    xls = Axlsx::Package.new
    xls.workbook do |wb|
      wb.add_worksheet(name: "tags_#{Time.now.to_date}") do |sheet|
        sheet.add_row Tag::CSV_EXPORT_COLUMN_HEADERS[:tag].values

        all.each do |tag|
          sheet.add_row tag.csv_mapped_attributes
        end
      end
    end
    xls
  end

  def self.export(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)

    query = self.all
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?

    if params[:category_ids].present? && params[:category_ids].reject(&:blank?).present?
      query = query.where(category_id: params[:category_ids].reject(&:blank?))
    end

    query
  end

  def self.grid_filter_dropdowns
    h = {}
    h[:category] = Site.current.categories.active.order(name: :asc).map do |category|
      { category.id => category.name }
    end
    h[:category].insert(0, { '' => 'all' })
    h
  end
end
