
RSpec.shared_context 'a basic frontend' do

  let!(:country) { FactoryGirl.create(:country, id: 1, name: 'Spain', locale: 'es-ES' ) }
  let!(:country2) { FactoryGirl.create(:country, id: 2, name: 'Brasil', locale: 'pt-BR' ) }

  let!(:site) { FactoryGirl.create(:site, id: 1, hostname: '127.0.0.1', country: country, time_zone: 'Madrid') }
  let!(:site2) { FactoryGirl.create(:site, id: 2, hostname: 'cupon.es', country: country2, time_zone: 'America/Sao_Paulo') }

  before do
    DynamicRoutes.reload
    set_app_host site.hostname
  end

end

RSpec.shared_context 'a full frontend' do

  include_context 'a basic frontend'
  include_context 'a valid shop with coupons'
  include_context 'with additional shops, coupons and categories'
  include_context 'with widgets'

end

RSpec.shared_context 'a valid shop with coupons' do

  let!(:category) { FactoryGirl.create(:category, id: 1, name: 'Electronics', site: site, status: 'active') }
  let!(:category2) { FactoryGirl.create(:category, id: 2, name: 'Games', site: site2, status: 'active') }

  let!(:shop) { FactoryGirl.create(:shop, id: 1, title: 'Amazon', slug: 'amazon', site: site, status: 'active') }
  let!(:shop2) { FactoryGirl.create(:shop, id: 2, title: 'Zapatos', slug: 'zapatos', site: site2, status: 'active') }

  let!(:coupon) { FactoryGirl.create(:full_coupon, id: 1, site: site, shop: shop, status: 'active', categories: [category])}
  let!(:coupon2) { FactoryGirl.create(:full_coupon, id: 2, site: site2, shop: shop2, status: 'active', categories: [category2])}

  let!(:coupon_expired) {
    c = FactoryGirl.build(:coupon, id: 3, site: site , end_date: 7.days.ago, status: 'active')
    c.save(validate: false)
    c
  }

  let!(:coupon_expired2) {
    c = FactoryGirl.build(:coupon, id: 4, site: site2 , end_date: 7.days.ago, status: 'active')
    c.save(validate: false)
    c
  }

  let!(:more_coupon_expired) {
    c = FactoryGirl.build(:coupon, id: 5, site: site , end_date: 7.days.ago, status: 'active')
    c.save(validate: false)
    c
  }

  let!(:more_coupon_expired2) {
    c = FactoryGirl.build(:coupon, id: 6, site: site2 , end_date: 7.days.ago, status: 'active')
    c.save(validate: false)
    c
  }

end

RSpec.shared_context 'with additional shops, coupons and categories' do

  let!(:category3) { FactoryGirl.create(:category, id: 3, name: 'Games', site: site, status: 'active') }
  let!(:category4) { FactoryGirl.create(:category, id: 4, name: 'Sports', site: site, status: 'active') }
  let!(:category5) { FactoryGirl.create(:category, id: 5, name: 'Toys', site: site, status: 'active') }

  let!(:shop3) { FactoryGirl.create(:shop, id: 3, title: 'shop3', slug: 'shop3', site: site, status: 'active') }
  let!(:shop4) { FactoryGirl.create(:shop, id: 4, title: 'shop4', slug: 'shop4', site: site, status: 'active') }
  let!(:shop5) { FactoryGirl.create(:shop, id: 5, title: 'shop5', slug: 'shop5', site: site, status: 'active') }

  let!(:coupon3) { FactoryGirl.create(:full_coupon, id: 7, site: site, shop: shop3, status: 'active', categories: [category3])}
  let!(:coupon4) { FactoryGirl.create(:full_coupon, id: 8, site: site, shop: shop4, status: 'active', categories: [category4])}
  let!(:coupon5) { FactoryGirl.create(:full_coupon, id: 9, site: site, shop: shop5, status: 'active', categories: [category5])}

end

RSpec.shared_context 'with widgets' do

  let!(:widget_category) { FactoryGirl.create(:widget_category, title: 'widget_category', site_id: site.id) }
  let!(:widget_category2) { FactoryGirl.create(:widget_category, title: 'widget_category2', site_id: site2.id) }

  let!(:widget_newsletter) { FactoryGirl.create(:widget_newsletter, title: 'widget_newsletter', site_id: site.id) }
  let!(:widget_newsletter2) { FactoryGirl.create(:widget_newsletter, title: 'widget_newsletter2', site_id: site2.id) }

  let!(:widget_area) { FactoryGirl.create(:widget_area, site_id: site.id, value: OpenStruct.new(widget_order: [widget_newsletter.id, widget_category.id]) )}
  let!(:widget_area2) { FactoryGirl.create(:widget_area, site_id: site2.id, value: OpenStruct.new(widget_order: [widget_newsletter2.id, widget_category2.id]) )}

  let!(:widget_area_sidebar) { FactoryGirl.create(:widget_area_sidebar, site_id: site.id, value: OpenStruct.new(widget_order: [widget_newsletter.id]) )}
  let!(:widget_area_sidebar2) { FactoryGirl.create(:widget_area_sidebar, site_id: site2.id, value: OpenStruct.new(widget_order: [widget_newsletter2.id]) )}

  let!(:widget_area_footer) { FactoryGirl.create(:widget_area_footer, site_id: site.id, value: OpenStruct.new(widget_order: [widget_newsletter.id]) )}
  let!(:widget_area_footer2) { FactoryGirl.create(:widget_area_footer, site_id: site2.id, value: OpenStruct.new(widget_order: [widget_newsletter2.id]) )}

end

RSpec.shared_context 'a campaign with widgets' do

  let!(:campaign) { FactoryGirl.create(:campaign, site_id: site.id)}

  let!(:campaign_widget_newsletter) { FactoryGirl.create(:widget_newsletter, campaign_id: campaign.id, title: 'widget_newsletter', site_id: site.id) }
  let!(:campaign_widget_category) { FactoryGirl.create(:widget_category, campaign_id: campaign.id, title: 'widget_category', site_id: site.id) }

  let!(:campaign_widget_area) { FactoryGirl.create(:widget_area, campaign_id: campaign.id, site_id: site.id, value: OpenStruct.new(widget_order: [campaign_widget_newsletter.id, campaign_widget_category.id]) )}
  let!(:campaign_widget_area_sidebar) { FactoryGirl.create(:widget_area_sidebar, campaign_id: campaign.id, site_id: site.id, value: OpenStruct.new(widget_order: [campaign_widget_newsletter.id]) )}
  let!(:campaign_widget_area_footer) { FactoryGirl.create(:widget_area_footer, campaign_id: campaign.id, site_id: site.id, value: OpenStruct.new(widget_order: [campaign_widget_newsletter.id]) )}

  let!(:tag) { FactoryGirl.create(:tag, word: 'my-tag')}

end

RSpec.shared_context 'a static page' do
  let!(:static_page) { FactoryGirl.create(:static_page, site_id: site.id)}
end

RSpec.shared_context 'with js' do
  before do
    if example.metadata[:js]
      sleep 0.1
      Capybara.reset_sessions!
      sleep 0.1
      page.driver.reset!
      sleep 0.1
      page.driver.clear_network_traffic
      sleep 0.1
    end
  end
end
