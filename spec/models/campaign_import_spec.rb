require 'fog_helper'

describe CampaignImport, type: :model do
  let!(:country) { create :country, id: 1, name: 'Spain' }
  let!(:other_country) { create :country, id: 2, name: 'Germany' }
  let!(:site) { create :site, id: 1, hostname: 'test.host', country: country, time_zone: 'UTC' }
  let!(:other_site) { create :site, id: 2, hostname: 'test1.host', country: other_country }
  let!(:campaign_import_file) { Rails.root.join('spec/support/files/campaign_import.xlsx') }
  let!(:country_manager) do
    create :country_manager, countries: [country]
    CountryManager.first
  end

  describe 'validates' do
    let(:campaign_import_file_without_site_id) { Rails.root.join('spec/support/files/campaign_import_without_site_id.xlsx') }

    before do
      country_manager.countries << country
      User.current = country_manager
    end

    it 'true with allowed Site ID' do
      expect(FactoryGirl.build(:campaign_import, file: File.open(campaign_import_file), user_id: 1)).to be_valid
    end

    it 'false without User ID' do
      expect(FactoryGirl.build(:campaign_import, file: File.open(campaign_import_file))).to be_valid
    end

    it 'false if Site ID is not allowed' do
      User.current.countries = [other_country]
      expect(FactoryGirl.build(:campaign_import, file: File.open(campaign_import_file), user_id: 1)).not_to be_valid
    end

    it 'false without Site ID in xls head' do
      expect(FactoryGirl.build(:campaign_import, file: File.open(campaign_import_file_without_site_id), user_id: 1)).not_to be_valid
    end
  end

  describe 'run' do
    let!(:affiliate_network) { create :affiliate_network, slug: 'test' }
    let!(:shop) { create :shop, site: site, slug: 'test' }

    before do
      Time.zone = 'UTC'
      User.current = country_manager
      @campaign_import = FactoryGirl.build(:campaign_import, file: File.open(campaign_import_file))
      @campaign_import.user_id = country_manager.id
      @campaign_import.status = 'pending'
      @campaign_import.run
    end

    it 'updates campaign_import status to done' do
      expect(@campaign_import.status).to eq('done')
    end

    it 'imports campaigns' do
      parent = Campaign.first
      child = Campaign.last

      expect(parent.name).to eq('parent')
      expect(parent.is_root_campaign).to eq(true)
      expect(child.is_root_campaign).to eq(false)
      expect(parent.priority_coupon_ids.to_s).to eq('1')
      expect(parent.start_date.to_s(:db)).to eq('2018-01-01 00:00:00')
      expect(parent.end_date.to_s(:db)).to eq('2018-12-31 23:59:59')
      expect(parent.h1_first_line).to eq('test')
      expect(parent.h1_second_line).to eq('test')
      expect(parent.nav_title).to eq('test')
      expect(parent.slug).to eq('parent')
      expect(parent.status).to eq('active')
      expect(parent.html_document.h2).to eq('test')
      expect(parent.html_document.meta_robots).to eq('test')
      expect(parent.html_document.meta_keywords).to eq('test')
      expect(parent.html_document.meta_description).to eq('test')
      expect(parent.html_document.meta_title).to eq('test')
      expect(parent.html_document.welcome_text).to eq('test')
    end
  end
end
