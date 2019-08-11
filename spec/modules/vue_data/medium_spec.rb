require 'fog_helper'

describe VueData::Medium do
  let!(:site) { create :site }
  let!(:other_site) { create :site }
  let!(:mediums) { create_list :medium, 2, site: site }
  let!(:other_mediums) { create_list :medium, 3, site: other_site }


  context '::render_json' do

    context 'succeeds' do
      it 'with single site' do
        expect(JSON.parse(VueData::Medium.render_json(site.id))['count']).to eq(mediums.count)
      end

      it 'with multiple sites' do
        expect(JSON.parse(VueData::Medium.render_json([site.id, other_site.id]))['count']).to eq(Medium.count)
      end
    end

    context 'returns' do
      subject { JSON.parse(VueData::Medium.render_json(site.id))['records'].first.keys }

      it { is_expected.to match_array(%w(id file_name thumbnail created_at)) }
    end
  end
end
