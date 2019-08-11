describe 'Coupons' do

  # include_context 'a basic frontend'
  # include_context 'with widgets'

  let!(:category) { FactoryGirl.create(:main_category, id: 1, name: 'Electronics', site: site, status: 'active') }
  let!(:category2){ FactoryGirl.create(:main_category, id: 2, name: 'Games', site: site2, status: 'active') }

  let!(:shop)     { FactoryGirl.create(:shop, id: 1, title: 'Amazon', slug: 'amazon', site: site, status: 'active') }
  let!(:shop2)    { FactoryGirl.create(:shop, id: 2, title: 'Zapatos', slug: 'zapatos', site: site2, status: 'active') }

  let!(:coupon)   { FactoryGirl.create(:full_coupon, id: 1, site: site, shop: shop, status: 'active', categories: [category])}
  let!(:coupon2)  { FactoryGirl.create(:full_coupon, id: 2, site: site2, shop: shop2, status: 'active', categories: [category2])}
  let!(:coupon3)  { FactoryGirl.create(:full_coupon, id: 3, site: site, shop: shop, status: 'active')}
  let!(:coupon4)  { FactoryGirl.create(:full_coupon, id: 4, site: site, shop: shop, status: 'active')}

  def check_coupon_breadcrumb type
    expect(page.find('.breadcrumbs')).to have_content I18n.t(type.to_sym, default: type)
  end

  context 'index' do

    before do
      visit send("coupons_top_#{site.id}_path")
    end

    # include_examples 'sidebar with widgets and expiring coupons'

    context 'orders' do

      xit 'order_position ASC before coupons' do

        coupon.update_attributes(is_top: 1, order_position: 1)
        coupon3.update_attributes(is_top: 1, order_position: 2)
        coupon4.update_attributes(is_top: 1, order_position: nil, coupon_type: 'coupon', code: 'adfasdf')

        visit send("coupons_top_#{site.id}_path")

        expect(page.find('.coupons-list li:nth-child(1)')).to have_content coupon.title
        expect(page.find('.coupons-list li:nth-child(2)')).to have_content coupon3.title
        expect(page.find('.coupons-list li:nth-child(3)')).to have_content coupon4.title

        # Reverse Check
        coupon.update_attributes(is_top: 1, order_position: nil, coupon_type: 'coupon', code: 'adfasdf')
        coupon3.update_attributes(is_top: 1, order_position: 2)
        coupon4.update_attributes(is_top: 1, order_position: 1)

        visit send("coupons_top_#{site.id}_path")

        expect(page.find('.coupons-list li:nth-child(1)')).to have_content coupon4.title
        expect(page.find('.coupons-list li:nth-child(2)')).to have_content coupon3.title
        expect(page.find('.coupons-list li:nth-child(3)')).to have_content coupon.title

      end

      xit 'coupons before offers before older offers' do

        coupon.update_attributes(is_top: 1, coupon_type: 'coupon', code: 'adfasdf')
        coupon3.update_attributes(is_top: 1, coupon_type: 'offer', code: nil, start_date: Time.zone.now - 1.hour)
        coupon4.update_attributes(is_top: 1, coupon_type: 'offer', code: nil, start_date: Time.zone.now - 3.hours)

        visit send("coupons_top_#{site.id}_path")

        expect(page.find('.coupons-list li:nth-child(1)')).to have_content coupon.title
        expect(page.find('.coupons-list li:nth-child(2)')).to have_content coupon3.title
        expect(page.find('.coupons-list li:nth-child(3)')).to have_content coupon4.title

        # reverse check
        coupon.update_attributes(is_top: 1, coupon_type: 'offer', code: nil, start_date: Time.zone.now - 3.hours)
        coupon3.update_attributes(is_top: 1, coupon_type: 'offer', code: nil, start_date: Time.zone.now - 1.hour)
        coupon4.update_attributes(is_top: 1, coupon_type: 'coupon', code: 'adfasdf')

        visit send("coupons_top_#{site.id}_path")

        expect(page.find('.coupons-list li:nth-child(1)')).to have_content coupon.title
        expect(page.find('.coupons-list li:nth-child(2)')).to have_content coupon3.title
        expect(page.find('.coupons-list li:nth-child(3)')).to have_content coupon4.title

      end

      xit 'higher savings first' do

        coupon.update_attributes(is_top: 1, coupon_type: 'offer', savings: 10)
        coupon3.update_attributes(is_top: 1, coupon_type: 'offer', savings: 5)
        coupon4.update_attributes(is_top: 1, coupon_type: 'offer', savings: 1)

        visit send("coupons_top_#{site.id}_path")

        expect(page.find('.coupons-list li:nth-child(1)')).to have_content coupon.title
        expect(page.find('.coupons-list li:nth-child(2)')).to have_content coupon3.title
        expect(page.find('.coupons-list li:nth-child(3)')).to have_content coupon4.title

        # reverse check
        coupon.update_attributes(is_top: 1, coupon_type: 'offer', savings: 1)
        coupon3.update_attributes(is_top: 1, coupon_type: 'offer', savings: 5)
        coupon4.update_attributes(is_top: 1, coupon_type: 'offer', savings: 10)

        visit send("coupons_top_#{site.id}_path")

        expect(page.find('.coupons-list li:nth-child(1)')).to have_content coupon.title
        expect(page.find('.coupons-list li:nth-child(2)')).to have_content coupon3.title
        expect(page.find('.coupons-list li:nth-child(3)')).to have_content coupon4.title

      end

    end

    context 'TOP' do

      xit 'shows the right coupons' do
        coupon.update_attributes(is_top: 1)
        coupon2.update_attributes(site_id: site2.id, is_top: 1) # from a foreign site
        coupon3.update_attributes(is_top: 0)

        visit send("coupons_top_#{site.id}_path")

        check_coupon_breadcrumb site.hostname.capitalize
        check_coupon_breadcrumb 'COUPON_LIST_NAV_TOP'

        expect(page.find('.coupons-list')).to have_content coupon.title
        expect(page.find('.coupons-list')).to_not have_content coupon2.title
        expect(page.find('.coupons-list')).to_not have_content coupon3.title
      end

    end

    context 'NEW' do

      xit 'shows the right coupons' do

        coupon.update_attributes(start_date: Time.zone.now - 1.day)
        coupon2.update_attributes(site_id: site2.id, start_date: Time.zone.now - 1.day) # from a foreign site
        coupon3.update_attributes(start_date: Time.zone.now + 3.days)

        visit send("coupons_new_#{site.id}_path")

        check_coupon_breadcrumb site.hostname.capitalize
        check_coupon_breadcrumb 'COUPON_LIST_NAV_NEW'

        expect(page.find('.coupons-list')).to have_content coupon.title
        expect(page.find('.coupons-list')).to_not have_content coupon2.title
        expect(page.find('.coupons-list')).to_not have_content coupon3.title
      end
    end

    context 'EXCLUSIVE' do

      xit 'shows the right coupons' do

        coupon.update_attributes(is_exclusive: 1)
        coupon2.update_attributes(site_id: 2, is_exclusive: 1) # from a foreign site
        coupon3.update_attributes(is_exclusive: 0)

        visit send("coupons_exclusive_#{site.id}_path")

        check_coupon_breadcrumb site.hostname.capitalize
        check_coupon_breadcrumb 'COUPON_LIST_NAV_EXCLUSIVE'

        expect(page.find('.coupons-list')).to have_content coupon.title
        expect(page.find('.coupons-list')).to_not have_content coupon2.title
        expect(page.find('.coupons-list')).to_not have_content coupon3.title
      end
    end

    context 'FREE' do

      xit 'shows the right coupons' do
        coupon.update_attributes(is_free_delivery: 1)
        coupon2.update_attributes(site_id: 2, is_free_delivery: 1) # from a foreign site
        coupon3.update_attributes(is_free_delivery: 0)

        visit send("coupons_free_delivery_#{site.id}_path")

        check_coupon_breadcrumb site.hostname.capitalize
        check_coupon_breadcrumb 'COUPON_LIST_NAV_FREE'

        expect(page.find('.coupons-list')).to have_content coupon.title
        expect(page.find('.coupons-list')).to_not have_content coupon2.title
        expect(page.find('.coupons-list')).to_not have_content coupon3.title
      end
    end

    context 'EXPIRING' do

      xit 'shows the right coupons' do

        coupon.update_attributes(end_date: Time.zone.now + 2.days)
        coupon2.update_attributes(site_id: 2, end_date: Time.zone.now + 2.days) # from a foreign site
        coupon3.update_attributes(end_date: Time.zone.now + 10.days)

        visit send("coupons_expiring_#{site.id}_path")

        check_coupon_breadcrumb site.hostname.capitalize
        check_coupon_breadcrumb 'COUPON_LIST_NAV_EXPIRING'

        expect(page.find('.coupons-list')).to have_content coupon.title
        expect(page.find('.coupons-list')).to_not have_content coupon2.title
        expect(page.find('.coupons-list')).to_not have_content coupon3.title
      end
    end
  end
end
