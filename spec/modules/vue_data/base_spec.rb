describe VueData::Base do
  let(:site) { create :site }

  context '::render_json' do
    it 'fails if Base class is called' do
      expect{ VueData::Base.render_json(1) }.to raise_error(NotImplementedError)
    end

    context 'inherited' do
      it 'fails if site_ids blank' do
        expect{ VueData::Coupon.render_json }.to raise_error(ArgumentError)
      end

      context 'returns defaults' do
        subject { JSON.parse(VueData::Coupon.render_json(site.id)) }

        it { is_expected.to  include({ 'page' => 1, 'order' => 'id', 'per_page' => 20, 'order_direction' => 'desc' }) }
      end

      context 'overwrites defaults' do
        subject { JSON.parse(VueData::Coupon.render_json(site.id, page: 2, order: 'title', order_direction: 'asc', per_page: 10)) }

        it { is_expected.to  include({ 'page' => 2, 'order' => 'title', 'per_page' => 10, 'order_direction' => 'asc' }) }
      end
    end
  end
end
