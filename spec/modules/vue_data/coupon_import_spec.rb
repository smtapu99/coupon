require 'fog_helper'

describe VueData::CampaignImport do
  let!(:country) { create :country, name: 'Spain' }
  let!(:site) { create :site, id: 1, hostname: 'test.host', country: country, time_zone: 'UTC' }
  let!(:coupon_import_file) { Rails.root.join("spec/support/files/coupon_import.xlsx") }
  let!(:country_manager) {create :country_manager, countries: [country] }

  context '::render_json' do

    before { User.current = country_manager }
    let!(:coupon_imports) { create_list :coupon_import, 2, file: File.open(coupon_import_file), user_id: country_manager.id }

    context 'succeeds' do

      it 'with returnes coupon imports' do
        expect(JSON.parse(VueData::CouponImport.render_json(nil))['count']).to eq(coupon_imports.count)
      end

      it 'with order by user' do
        expect(JSON.parse(VueData::CouponImport.render_json(nil, order: 'user', direction: 'asc'))['count']).to eq(coupon_imports.count)
      end

    end

    context 'returns' do
      subject { JSON.parse(VueData::CouponImport.render_json(nil))['records'].first.keys }

      it { is_expected.to match_array(%w(id status file user created_at)) }
    end
  end
end
