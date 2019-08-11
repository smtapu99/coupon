describe PartnerForm, :type => :model do
  let(:site) { create :site }
  let(:partner_form) { build :partner_form }

  before do
    Site.current = site
    Time.zone = 'UTC'
  end

  describe '#factory' do
    it "has a valid factory" do
        expect(build :partner_form).to be_valid
    end
  end

  describe '#attributes' do
    it "should include the :name attribute" do
      expect(partner_form).to have_attributes(:name => "Test", :email => 'test@test.com')
    end

    it "is not valid without a name" do
      partner_form = build :partner_form, name: nil
      expect(partner_form).to_not be_valid
    end

    it "is not valid without a email" do
      partner_form = build :partner_form, email: nil
      expect(partner_form).to_not be_valid
    end

    it "is valid without a domain" do
      partner_form = build :partner_form, domain: nil
      expect(partner_form).to be_valid
    end

    it "is valid without a message" do
      partner_form = build :partner_form, message: nil
      expect(partner_form).to be_valid
    end

    it "requires an valid email" do
      partner_form = build :partner_form, email: "test@test.com"
      expect(partner_form).to be_valid
    end

    it "invalid email" do
      partner_form = build :partner_form, email: "test.test.com"
      expect(partner_form).to_not be_valid
    end
  end

  describe '#headers' do
    it "should declare appropriate email headers" do
      partner_form = build :partner_form
      expect(partner_form.headers).to include(:from, :reply_to, :subject, :to)
    end
  end
end
