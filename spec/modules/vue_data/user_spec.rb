describe VueData::User do
  let!(:country) { create :country, name: 'Spain' }
  let!(:super_admin) { create :super_admin, countries: [country] }
  let!(:users) { create_list :user, 5, countries: [country] }

  context '::render_json' do

    context 'succeeds' do

      before { User.current = super_admin }

      it 'returnes sites' do
        expect(JSON.parse(VueData::User.render_json(nil))['count']).to eq(User.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::User.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id status first_name last_name email role)) }
    end
  end
end
