require 'fog_helper'

describe TagImport, type: :model do
  it 'has a valid factory' do
    expect(build :tag_import).to be_valid
  end

  describe 'run' do
    let!(:site) { create :site }
    let!(:other_site) { create :site }
    let!(:category) { create :category, slug: 'fashion', site: site  }
    let!(:other_category) { create :category, slug: 'fashion', site: other_site }

    before do
      Time.zone = 'UTC'
      Site.current = other_site
      @tag_import = FactoryGirl.build(:tag_import, file: File.open(Rails.root.join('spec/support/files/tag_import.xlsx')))
      @tag_import.site_id = Site.current.id
      @tag_import.status = 'pending'
      @tag_import.run
    end

    it 'updates tag_imports status to done' do
      expect(@tag_import.status).to eq('done')
    end

    it 'imports tags' do
      expect(Tag.count).to eq(2)
      expect(Tag.first.word).to eq('aaa')
      expect(Tag.first.category).to eq(other_category)
      expect(Tag.first.is_blacklisted).to eq(true)
    end
  end
end
