require 'fog_helper'

describe VueData::ShopImport do
  let!(:country) { create :country, name: 'Spain' }
  let!(:site) { create :site, id: 1, hostname: 'test.host', country: country, time_zone: 'UTC' }
  let!(:shop_import_file) { Rails.root.join("spec/support/files/shop_import.xlsx") }
  let!(:country_manager) {create :country_manager, countries: [country] }

  context '::render_json' do

    before { User.current = country_manager }
    let!(:shop_imports) { create_list :shop_import, 2, file: File.open(shop_import_file), user_id: country_manager.id }

    context 'succeeds' do

      it 'with returnes coupon imports' do
        expect(JSON.parse(VueData::ShopImport.render_json(nil))['count']).to eq(shop_imports.count)
      end

      it 'with order by user' do
        expect(JSON.parse(VueData::ShopImport.render_json(nil, order: 'user', direction: 'asc'))['count']).to eq(shop_imports.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::ShopImport.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id status file user created_at)) }
    end
  end
end
