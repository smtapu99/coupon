describe AffiliateNetwork do

  it_behaves_like 'status validator'

  it "Has a valid factory." do
    expect(FactoryGirl.create(:affiliate_network)).to be_valid
  end

  it "Is invalid without a name." do
    expect(FactoryGirl.build(:affiliate_network, name: nil)).not_to be_valid
  end

  it "Is invalid with incorrect status." do
    expect(FactoryGirl.build(:affiliate_network, status: 'test')).not_to be_valid
  end

  it "Returns a affiliate network's name as a string." do
    affiliate_network = FactoryGirl.build(:affiliate_network, name: 'Affiliate Network', slug: 'affiliate-network')
    expect(affiliate_network.name).to eq "Affiliate Network"
  end

  it "Returns a affiliate network's slug as a string." do
    affiliate_network = FactoryGirl.build(:affiliate_network, name: 'Affiliate Network', slug: 'affiliate-network')
    expect(affiliate_network.slug).to eq "affiliate-network"
  end

  it "Should have many coupons." do
    coupons = AffiliateNetwork.reflect_on_association(:coupons)
    expect(coupons.macro).to eq :has_many
  end

end
