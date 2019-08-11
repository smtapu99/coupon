describe VueData::Country do

  context '::render_json' do
    let!(:countries) { create_list :country, 2 }

    context 'succeeds' do
      it 'returns countries' do
        expect(JSON.parse(VueData::Country.render_json(nil))['count']).to eq(countries.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::Country.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id name locale)) }
    end
  end
end
