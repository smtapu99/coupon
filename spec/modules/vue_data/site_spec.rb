describe VueData::Site do
  let!(:country) { create :country, name: 'Spain' }
  let!(:site_1) { create :site, hostname: 'test1.host', country: country, time_zone: 'UTC' }
  let!(:site_2) { create :site, hostname: 'test2.host', country: country, time_zone: 'UTC' }
  let!(:country_manager) do
    create :country_manager, countries: [country]
  end

  context '::render_json' do

    context 'succeeds' do

      before { User.current = country_manager }

      it 'returns sites' do
        expect(JSON.parse(VueData::Site.render_json(nil))['count']).to eq(Site.count)
      end

      it 'with order by country' do
        expect(JSON.parse(VueData::Site.render_json(nil, order: 'country', direction: 'asc'))['count']).to eq(Site.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::Site.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id status name hostname time_zone country)) }
    end
  end
end
