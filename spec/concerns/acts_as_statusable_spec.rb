describe 'ActsAsStatusable' do
  context 'included' do
    let!(:affiliate_network) { create :affiliate_network }

    it 'contains STATUSES Hash' do
      expect(AffiliateNetwork.statuses).to be_a(Hash)
    end

    context 'when status' do
      it 'allowed' do
        expect(build :affiliate_network, status: 'active').to be_valid
      end

      it 'not allowed' do
        expect(build :affiliate_network, status: 'wrong').to_not be_valid
      end
    end
  end

  context 'is_{status}?' do
    context 'when correct' do
      subject { build(:affiliate_network, status: 'active').is_active? }
      it { is_expected.to eq(true) }
    end

    context 'when wrong' do
      subject { build(:affiliate_network, status: 'active').is_blocked? }
      it { is_expected.to eq(false) }
    end
  end
end
