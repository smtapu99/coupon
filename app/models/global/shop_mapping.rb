class Global::ShopMapping < ApplicationRecord
  belongs_to :country
  belongs_to :global

  validates :url_home, url: true
  before_save :extract_domain

  def self.grid_filter(params, country)
    global_ids = Shop.active.where(site_id: country.site_ids).pluck(:global_id).uniq

    query = Global.where(id: global_ids)
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('name like ?', "%#{params[:name]}%") if params[:name].present?
    query = query.where('url_home like ?', "%#{params[:url_home]}%") if params[:url_home].present?
    query = query.where('domain like ?', "%#{params[:domain]}%") if params[:domain].present?

    if params[:url_home].present? || params[:domain].present?
      query = query.joins(:global_shop_mappings)
      query = query.where('global_shop_mappings.url_home like ?', "%#{params[:url_home]}%") if params[:url_home].present?
      query = query.where('global_shop_mappings.domain like ?', "%#{params[:domain]}%") if params[:domain].present?
    end

    query
  end

  private

  def extract_domain
    return unless url_home.present?
    domain = PublicSuffix.parse(URI.parse(url_home).host)
    self.domain = domain.domain
  end
end
