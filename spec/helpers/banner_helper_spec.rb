describe BannerHelper do
  let!(:site) { create :site }

  context '.is_shops_show?' do
    subject { helper.is_shops_show? }

    context 'when is_shops_show?' do
      before do
        allow(controller).to receive(:controller_name) { 'shops' }
        allow(controller).to receive(:action_name) { 'show' }
      end

      it { is_expected.to eq(true) }
    end

    context 'else' do
      it { is_expected.to eq(false) }
    end
  end

  context '.is_category_show?' do
    subject { helper.is_category_show? }

    context 'when is_category_show?' do
      before do
        allow(controller).to receive(:controller_name) { 'categories' }
        allow(controller).to receive(:action_name) { 'show' }
      end
      it { is_expected.to eq(true) }
    end

    context 'else' do
      it { is_expected.to eq(false) }
    end
  end

  context '.is_campaign_sem?' do
    subject { helper.is_campaign_sem? }

    context 'when is_campaign_sem?' do
      before do
        allow(controller).to receive(:controller_name) { 'campaigns' }
        allow(controller).to receive(:action_name) { 'sem' }
      end
      it { is_expected.to eq(true) }
    end

    context 'else' do
      it { is_expected.to eq(false) }
    end
  end

  context '.show_flyout_notification?' do
    before do
      Site.current = site

      @coupons = create_list :coupon, 2, site: site
      @shop = create :shop, site: site

      allow(controller).to receive(:controller_name) { 'shops' }
      allow(controller).to receive(:action_name) { 'show' }

      site.setting = Setting.new(experimental: { shops_with_flyout_coupon: [@shop.id.to_s] }, site: site)
    end

    subject { helper.show_flyout_notification? }

    context 'when is shops_show and @shop.present? and @coupon.present? and experimental.shops_with_flyout_coupon includes @shop' do
      it { is_expected.to eq(true) }
    end

    context 'when isnt shops/show' do
      before { allow(controller).to receive(:action_name) { 'index' } }
      it { is_expected.to eq(false) }
    end

    context 'when @shop.blank?' do
      before { @shop = nil }
      it { is_expected.to eq(false) }
    end

    context 'when @coupons.blank?' do
      before { @coupons = nil }
      it { is_expected.to eq(false) }
    end

    context 'when setting nil' do
      before { site.setting.update(experimental: {}) }
      it { is_expected.to eq(false) }
    end
  end
end
