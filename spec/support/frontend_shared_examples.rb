RSpec.shared_examples "sidebar with widgets" do

  it 'shows the sidebar widgets' do
    expect(page).to have_selector('.box-text')
    expect(page).to have_selector('.box-newsletter')
  end

end

RSpec.shared_examples "sidebar with widgets and expiring coupons" do

  include_examples 'sidebar with widgets'

  it 'shows expiring coupons in the sidebar' do
    expect(page).to have_content I18n.t :EXPIRING_COUPONS, default: 'EXPIRING_COUPONS'
    expect(page).to have_selector('#sidebar .box-related-coupons li', count: site.coupons.active.joins(:shop).order(end_date: :desc).to_a.count)
  end

end

RSpec.shared_examples "sidebar with widgets and related coupons" do

  include_examples 'sidebar with widgets'

  let!(:coupon6) { FactoryGirl.create(:full_coupon, id: 10, site: site, shop: shop3, status: 'active', categories: [category])}

  it 'shows expiring coupons in the sidebar' do
    visit(send("shop_show_#{site.id}_path", slug: shop.slug))
    expect(page).to have_content I18n.t :RELATED_COUPONS, default: 'RELATED_COUPONS'
    expect(page).to have_selector('#sidebar .box-related-coupons li', count: 1)
  end

end
