describe CouponHelper do
  include ApplicationHelper

  let!(:site) { create :site, hostname: 'test.host' }

  context '.coupon_title_heading' do
    let!(:shop) { create :shop }
    subject { helper.coupon_title_heading }

    context 'when not shops show' do
      it { is_expected.to eq(:h3) }
    end

    context 'when in shops show and' do
      before do
        @shop = shop
        controller.params[:controller] = 'shops'
        controller.params[:action] = 'show'
        Site.current = site
      end

      context 'shop in experimental.shops_with_elevated_coupons' do
        let!(:setting) { create :setting, experimental: { shops_with_elevated_coupons: [shop.id] }, site: site }
        it { is_expected.to eq(:h2) }
      end

      context 'shop NOT in experimental.shops_with_elevated_coupons' do
        it { is_expected.to eq(:h3) }
      end
    end
  end

  context '.render_clickout_params_string_for' do
    let!(:coupon) { create :coupon }

    before { Site.current = site }

    it 'when element.nil?' do
      expect(render_clickout_params_string_for(coupon)).to eq("data-coupon-id='#{coupon.id}' data-shop-name='#{coupon.shop.title}' data-coupon-title='#{coupon.title}' data-coupon-url='#{helper.dynamic_url_for('coupon', 'clickout', coupon.id)}' href='#id-#{coupon.id}' target='_blank'")
    end
  end

  context '.clickout_params_for_element' do
    let!(:coupon) { create :coupon }
    it 'when element.nil?' do
      Site.current = site
      expect(helper.clickout_params_for_element(coupon)).to eq(helper.render_clickout_params_string_for(coupon))
    end

    it 'when element == "li" and site.id = 1' do
      Site.current = Site.find_by(id: 1) || create(:site, id: 1)
      expect(helper.clickout_params_for_element(coupon, 'li')).to eq(helper.render_clickout_params_string_for(coupon))
    end

    it 'when element.nil?' do
      site.update(id: 0)
      Site.current = site.reload
      expect(helper.clickout_params_for_element(coupon, 'button')).to eq(helper.render_clickout_params_string_for(coupon))
    end
  end

  context '.default_logo_texts' do
    let!(:coupon) { create :coupon }

    it "when coupon.logo_text_first_line.present? && coupon.logo_text_second_line.present?" do
      coupon.update(logo_text_first_line: 'first', logo_text_second_line: 'second')
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'first', second_line: 'second')
    end

    it "when coupon.coupon_type == 'coupon' && coupon.savings.present? && coupon.savings.to_i > 0" do
      coupon.update(coupon_type: 'coupon', savings: 10, savings_in: 'percent')
      expect(helper.default_logo_texts(coupon)).to include(first_line: '<b>10</b>%', second_line: 'Coupon')
    end

    it "when coupon.coupon_type == 'coupon' && coupon.is_top" do
      coupon.update(coupon_type: 'coupon', is_top: true)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Top', second_line: 'Coupon')
    end

    it "when coupon.coupon_type == 'coupon' && coupon.is_free" do
      coupon.update(coupon_type: 'coupon', is_free: true)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Free', second_line: 'Coupon')
    end

    it "when coupon.is_free_delivery" do
      coupon.update(is_free_delivery: true)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Free', second_line: 'Delivery')
    end

    it "when coupon.coupon_type == 'offer' && coupon.savings.present? && coupon.savings.to_i > 0" do
      coupon.update(coupon_type: 'offer', savings: 10, savings_in: 'percent')
      expect(helper.default_logo_texts(coupon)).to include(first_line: '<b>10</b>%', second_line: 'Offer')
    end

    it "when coupon.coupon_type == 'offer' && coupon.is_top" do
      coupon.update(coupon_type: 'offer', is_top: true)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Top', second_line: 'Offer')
    end

    it "when coupon.coupon_type == 'offer' && coupon.is_free" do
      coupon.update(coupon_type: 'offer', is_free: true)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Free', second_line: 'Offer')
    end

    it "default coupon" do
      coupon.update(coupon_type: 'coupon', savings: 0)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Mega', second_line: 'Coupon')
    end

    it "default offer" do
      coupon.update(coupon_type: 'offer', savings: 0)
      expect(helper.default_logo_texts(coupon)).to include(first_line: 'Mega', second_line: 'Offer')
    end

    context 'orders' do
      it "coupon with savings before free_delivery" do
        coupon.update(coupon_type: 'coupon', is_free_delivery: true, savings: 10, savings_in: 'percent')
        expect(helper.default_logo_texts(coupon)).to include(first_line: '<b>10</b>%', second_line: 'Coupon')
      end

      it "offer with savings before free_delivery" do
        coupon.update(coupon_type: 'offer', is_free_delivery: true, savings: 10, savings_in: 'percent')
        expect(helper.default_logo_texts(coupon)).to include(first_line: '<b>10</b>%', second_line: 'Offer')
      end
    end
  end
end
