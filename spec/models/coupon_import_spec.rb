require 'fog_helper'

describe CouponImport, type: :model do
  let!(:country) { create :country, id: 1, name: 'Spain' }
  let!(:other_country) { create :country, id: 2, name: 'Germany' }
  let!(:site) { create :site, id: 1, hostname: 'test.host', country: country, time_zone: 'UTC' }
  let!(:other_site) { create :site, id: 2, hostname: 'test1.host', country: other_country }
  let!(:coupon_import_file) { Rails.root.join("spec/support/files/coupon_import.xlsx") }
  let!(:country_manager) do
    create :country_manager, countries: [country]
    CountryManager.first
  end

  describe 'validates' do
    let(:coupon_import_file_without_site_id) { Rails.root.join("spec/support/files/coupon_import_without_site_id.xlsx") }

    before do
      country_manager.countries << country
      User.current = country_manager
    end

    it 'true with allowed Site ID' do
      expect(FactoryGirl.build(:coupon_import, file: File.open(coupon_import_file), user_id: 1)).to be_valid
    end

    it 'false without User ID' do
      expect(FactoryGirl.build(:coupon_import, file: File.open(coupon_import_file))).to be_valid
    end

    it 'false if Site ID is not allowed' do
      User.current.countries = [other_country]
      expect(FactoryGirl.build(:coupon_import, file: File.open(coupon_import_file), user_id: 1)).not_to be_valid
    end

    it 'false without Site ID in xls head' do
      expect(FactoryGirl.build(:coupon_import, file: File.open(coupon_import_file_without_site_id), user_id: 1)).not_to be_valid
    end
  end

  describe 'run' do
    let!(:affiliate_network) { create :affiliate_network, slug: 'test' }
    let!(:shop) { create :shop, slug: 'test', site: site }
    let!(:category) { create :category, slug: 'test', site: site }
    let!(:campaign) { create :campaign, slug: 'campaign-1', site: site }

    before do
      Time.zone = 'UTC'
      User.current = country_manager
      @coupon_import = FactoryGirl.build(:coupon_import, file: File.open(coupon_import_file))
      @coupon_import.user_id = country_manager.id
      @coupon_import.status = 'pending'
      @coupon_import.run
    end

    it 'updates coupon_import status to done' do
      expect(@coupon_import.status).to eq('done')
    end

    it 'imports coupons' do
      coupon = Coupon.last

      expect(coupon.title).to eq('TEST')
      expect(coupon.site_id).to eq(1)
      expect(coupon.coupon_type).to eq('coupon')
      expect(coupon.code).to eq('123456')
      expect(coupon.shop.slug).to eq('test')
      expect(coupon.info_discount).to eq('test')
      expect(coupon.info_conditions).to eq('test')
      expect(coupon.info_min_purchase).to eq('test')
      expect(coupon.info_limited_brands).to eq('test')
      expect(coupon.info_limited_clients).to eq('test')
      expect(coupon.logo_text_first_line).to eq('test')
      expect(coupon.logo_text_second_line).to eq('test')
      expect(coupon.start_date.to_s(:db)).to eq('2018-01-01 00:00:00')
      expect(coupon.end_date.to_s(:db)).to eq('2018-12-31 23:59:59')
      expect(coupon.use_uniq_codes).to eq(true)
      expect(coupon.is_top).to eq(true)
      expect(coupon.is_exclusive).to eq(true)
      expect(coupon.is_editors_pick).to eq(true)
      expect(coupon.is_free).to eq(true)
      expect(coupon.is_mobile).to eq(true)
      expect(coupon.is_free_delivery).to eq(true)
      expect(coupon.is_hidden).to eq(true)
      expect(coupon.shop_list_priority).to eq(2)
      expect(coupon.url).to eq('http://test.de')
      expect(coupon.description).to eq('test description')
      expect(coupon.categories.first).to eq(category)
      expect(coupon.campaigns.first).to eq(campaign)
    end
  end
end
