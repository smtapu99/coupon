require 'fog_helper'

describe Widget do
  let!(:site) { create :site }

  it 'has a valid factory' do
    expect(FactoryGirl.build(:widget)).to be_valid
  end
end
