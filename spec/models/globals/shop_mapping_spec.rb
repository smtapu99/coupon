describe Global::ShopMapping, type: :model do

  it 'has a valid factory' do
    expect(build(:global_shop_mapping)).to be_valid
  end

  context 'extract_domain' do
    let!(:shop_mapping) { create :global_shop_mapping, url_home: 'http://test.de' }
    subject { Global::ShopMapping.last.domain }
    it { is_expected.to eq('test.de') }

    context 'when url_home includes www.' do
      before { shop_mapping.update(url_home: 'http://www.test.de') }
      it { is_expected.to eq('test.de') }
    end

    context 'when url_home includes subdomain.' do
      before { shop_mapping.update(url_home: 'http://test.test.de') }
      it { is_expected.to eq('test.de') }
    end

    context 'when url_home includes multipart TLD.' do
      before { shop_mapping.update(url_home: 'http://test.test.co.uk') }
      it { is_expected.to eq('test.co.uk') }
    end
  end
end
