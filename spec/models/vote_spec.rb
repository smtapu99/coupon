describe Vote, :type => :model do

  let(:site) { create :site }
  let(:shop) { create :shop, site: site }
  let(:tracking_user) { create :tracking_user }
  let(:keypunch) { Digest::SHA1.hexdigest("#{shop.id}-#{tracking_user.uniqid}") }
  let(:stars) { 2 }

  describe '::create' do
    subject { create :vote, stars: stars, keypunch: keypunch }
    it { is_expected.to be_a Vote }
    it { is_expected.to be_valid }
    it { is_expected.to have_attributes(keypunch: keypunch, stars: stars) }
  end

  describe '::find_by_keypunch_keys' do
    let!(:vote) { create :vote, stars: stars, keypunch: keypunch }
    subject { Vote.find_by_keypunch_keys(shop.id, tracking_user.uniqid).first.keypunch }
    it { is_expected.to eql(keypunch) }
  end

end

