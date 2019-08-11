describe "settings routes" do

  include_context 'a basic frontend'

  let!(:setting) { FactoryGirl.create(:setting_routes, site_id: site.id) }

  context 'defaults' do

    before do
      DynamicRoutes.reload
    end

    xit 'page_show_1_path' do
      expect(get: page_show_1_path(slug: 'abc')).to route_to controller:'pages', action: 'show'
    end

    xit 'category_1_path' do
      expect(get: categories_index_1_path).to route_to controller:'category', action: 'index'
    end

    # it 'category_show_1_path' do
    #   expect(get: category_show_1_path slug: 'abc').to route_to controller:'category', action: 'index'
    # end

    # it 'go_to_coupon_1_path' do
    #   expect(get: coupon_clickout_1_path 1).to route_to controller:'category', action: 'index'
    # end

    # it 'coupons_top_1_path' do
    #   expect(get: coupons_top_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'coupons_new_1_path' do
    #   expect(get: coupons_new_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'coupons_expiring_1_path' do
    #   expect(get: coupons_expiring_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'coupons_free_delivery_1_path' do
    #   expect(get: coupons_free_delivery_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'coupons_free_1_path' do
    #   expect(get: coupons_free_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'coupons_exclusive_1_path' do
    #   expect(get: coupons_exclusive_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'campaign_show_1_path' do
    #   expect(get: campaign_show_1_path slug: 'abc').to route_to controller:'category', action: 'index'
    # end

    # it 'shop_campaign_show_1_path' do
    #   expect(get: shop_campaign_show_1_path shop_slug: 'abc', slug: 'def').to route_to controller:'category', action: 'index'
    # end

    # it 'searches_index_1_path' do
    #   expect(get: searches_index_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'shops_index_1_path' do
    #   expect(get: shops_index_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'shop_show_1_path' do
    #   expect(get: shop_show_1_path slug: 'abc').to route_to controller:'category', action: 'index'
    # end

    # it 'contact_form_1_path' do
    #   expect(get: contact_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'partner_form_1_path' do
    #   expect(get: partner_1_path).to route_to controller:'category', action: 'index'
    # end

    # it 'report_form_1_path' do
    #   expect(get: report_1_path).to route_to controller:'category', action: 'index'
    # end


  end

end
