require 'fog_helper'

describe ShopImport, type: :model do
  let!(:country) { create :country, id: 1, name: 'Spain' }
  let!(:other_country) { create :country, id: 2, name: 'Germany' }
  let!(:site) { create :site, id: 1, hostname: 'test.host', country: country }
  let!(:other_site) { create :site, id: 2, hostname: 'test1.host', country: other_country }
  let!(:shop_import_file) { Rails.root.join('spec/support/files/shop_import.xlsx') }
  let!(:country_manager) do
    create :country_manager, countries: [country]
    CountryManager.first
  end

  describe 'validates' do
    let(:shop_import_file_without_site_id) { Rails.root.join('spec/support/files/shop_import_without_site_id.xlsx') }

    before do
      country_manager.countries << country
      User.current = country_manager
    end

    it 'true with allowed Site ID' do
      expect(FactoryGirl.build(:shop_import, file: File.open(shop_import_file), user_id: 1)).to be_valid
    end

    it 'false without User ID' do
      expect(FactoryGirl.build(:shop_import, file: File.open(shop_import_file))).to be_valid
    end

    it 'false if Site ID is not allowed' do
      User.current.countries = [other_country]
      expect(FactoryGirl.build(:shop_import, file: File.open(shop_import_file), user_id: 1)).not_to be_valid
    end

    it 'false without Site ID in xls head' do
      expect(FactoryGirl.build(:shop_import, file: File.open(shop_import_file_without_site_id), user_id: 1)).not_to be_valid
    end
  end

  describe 'run' do
    let!(:affiliate_network) { create :affiliate_network, slug: 'test' }

    before do
      User.current = country_manager
      @shop_import = FactoryGirl.build(:shop_import, file: File.open(shop_import_file))
      @shop_import.user_id = country_manager.id
      @shop_import.status = 'pending'
      @shop_import.run
    end

    it 'updates shop_import status to done' do
      expect(@shop_import.status).to eq('done')
    end

    it 'imports shops' do
      shop = Shop.last

      expect(shop.title).to eq('TEST')
      expect(shop.site_id).to eq(1)
      expect(shop.tier_group).to eq(1)
      expect(shop.status).to eq('active')
      expect(shop.anchor_text).to eq('test')
      expect(shop.slug).to eq('test')
      expect(shop.fallback_url).to eq('http://fallback.de')
      expect(shop.link_title).to eq('test')
      expect(shop.logo_alt_text).to eq('test')
      expect(shop.logo_title_text).to eq('test')
      expect(shop.is_hidden).to eq(true)
      expect(shop.is_top).to eq(true)
      expect(shop.is_default_clickout).to eq(false)
      expect(shop.is_direct_clickout).to eq(true)
      expect(shop.clickout_value).to eq(0.1)
      expect(shop.prefered_affiliate_network.slug).to eq('test')
      expect(shop.html_document.h1).to eq('test')
      expect(shop.html_document.h2).to eq('test')
      expect(shop.html_document.meta_robots).to eq('test')
      expect(shop.html_document.meta_keywords).to eq('test')
      expect(shop.html_document.meta_description).to eq('test')
      expect(shop.html_document.meta_title).to eq('test')
      expect(shop.html_document.meta_title_fallback).to eq('test')
      expect(shop.html_document.content).to eq('test')
      expect(shop.html_document.welcome_text).to eq('test')
      expect(shop.html_document.head_scripts).to eq('test')
    end
  end
end
