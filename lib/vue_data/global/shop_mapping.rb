class VueData::Global::ShopMapping < VueData::Base
  private

  def records
    @country = ::Country.find(@params[:country_id])
    ::Global::ShopMapping.grid_filter(params, @country)
  end

  def data(record)
    mapping = record.global_shop_mappings.find_by(country_id: @country.id)

    shops = ::Shop.active
      .includes(:site, :prefered_affiliate_network)
      .where(site_id: @country.site_ids, global_id: record.id)
      .where('affiliate_networks.slug is not null')
      .pluck('sites.name', 'affiliate_networks.slug').map do |set|
        "<b>#{set[0]}:</b> #{set[1]}"
      end.join("<br>").html_safe

    {
      id: record.id,
      name: record.name,
      url_home: mapping&.url_home,
      domain: mapping&.domain,
      affiliate_networks: shops
    }
  end
end
