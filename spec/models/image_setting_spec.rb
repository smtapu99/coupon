require 'fog_helper'

describe ImageSetting, type: :model do
  let!(:site) { create :site }

  it 'has a valid factory' do
    expect(FactoryGirl.build(:image_setting)).to be_valid
  end

  context '.favicon' do
    before { site.image_setting.update(favicon: File.open(Rails.root.join('spec/files/test.png'))) }

    it 'allows to upload a favicon' do
      expect(site.image_setting.favicon.path).to eq "image_setting/#{site.image_setting.id}/favicon/test.png"
    end
  end

  context '.hero' do
    before { site.image_setting.update(hero: File.open(Rails.root.join('spec/files/test.png'))) }

    it 'allows to upload a hero' do
      expect(site.image_setting.hero.path).to eq "image_setting/#{site.image_setting.id}/hero/test.png"
    end
  end

  context '.logo' do
    before { site.image_setting.update(logo: File.open(Rails.root.join('spec/files/test.png'))) }

    it 'allows to upload a logo' do
      expect(site.image_setting.logo.path).to eq "image_setting/#{site.image_setting.id}/logo/test.png"
    end
  end
end
