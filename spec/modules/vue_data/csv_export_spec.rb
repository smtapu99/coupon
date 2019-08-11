describe VueData::CsvExport do
  let!(:site) { create :site }
  let!(:user) { create :super_admin }
  context '::render_json' do
    let!(:csv_exports) { create_list :csv_export, 2 }

    context 'succeeds' do

      before { User.current = user }

      it 'returns csv exports' do
        expect(JSON.parse(VueData::CsvExport.render_json(nil))['count']).to eq(csv_exports.count)
      end

      it 'with order by user' do
        expect(JSON.parse(VueData::CsvExport.render_json(nil, order: 'user', direction: 'asc'))['count']).to eq(csv_exports.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::CsvExport.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id export_type status file user params created_at last_executed)) }
    end
  end
end
