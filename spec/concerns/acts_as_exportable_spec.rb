describe 'ActsAsExportable' do

  context 'Shop' do
    let!(:shop) { create :shop }

    context '.export_column_value' do
      subject { shop.export_column_value(key) }
      context 'booleans' do
        ['is_hidden',
          'is_top',
          'is_default_clickout',
          'is_direct_clickout'].each do |k|
          let(:key) { k }
          before { shop.update(key => true) }
          it { is_expected.to eq('yes') }
        end
      end

      context 'shop_category_ids' do
        let(:categories) { create_list :category, 2, site: shop.site }
        let(:key) { 'shop_category_ids' }
        before { shop.update(shop_category_ids: categories.map(&:id)) }
        it { is_expected.to eq("#{categories.first.id},#{categories.last.id}") }
      end

      context 'info_payment_methods' do
        let(:key) { 'info_payment_methods' }
        before { shop.update(info_payment_methods: ['', 'test', 'abc']) }
        it { is_expected.to eq("test,abc") }
      end

      context 'info_delivery_methods' do
        let(:key) { 'info_delivery_methods' }
        before { shop.update(info_delivery_methods: ['', 'abc', 'test']) }
        it { is_expected.to eq("abc,test") }
      end

      context 'standard values' do
        let(:key) { 'title' }
        before { shop.update(title: 'Title') }
        it { is_expected.to eq("Title") }
      end
    end
  end

  context 'Coupon' do
    let!(:coupon) { create :coupon }

    context '.export_column_value' do
      subject { coupon.export_column_value(key) }
      context 'booleans' do
        ['use_uniq_codes',
          'is_top',
          'is_exclusive',
          'is_editors_pick',
          'is_free',
          'is_hidden',
          'is_free_delivery',
          'is_mobile'].each do |k|
          let(:key) { k }
          before { coupon.update(key => true) }
          it { is_expected.to eq('yes') }
        end
      end

      context 'dates' do
        ['created_at', 'updated_at', 'start_date', 'end_date'].each do |k|
          let(:key) { k }
          before { coupon.update(key => Time.zone.now) }
          it { is_expected.to eq(coupon.send(key).to_date.strftime('%Y-%m-%d')) }
        end
      end
    end
  end

  context 'Campaign' do
    let!(:campaign) { create :campaign }

    context '.export_column_value' do
      subject { campaign.export_column_value(key) }

      context 'related_shop_ids' do
        let(:shops) { create_list :shop, 2, site: campaign.site }
        let(:key) { 'related_shop_ids' }
        before { campaign.update(related_shop_ids: shops.map(&:id)) }
        it { is_expected.to eq("#{shops.first.id},#{shops.last.id}") }
      end
    end
  end

end
