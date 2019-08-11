describe ContactForm, :type => :model do
  let(:site) { create :site }

  before do
    Site.current = site
    Time.zone = 'UTC'
  end

  describe '#factory' do
    it "has a valid factory" do
        expect(build :contact_form).to be_valid
    end
  end

  describe '#attributes' do
    it "should include the all attributes" do
      contact_form = build :contact_form
      expect(contact_form).to have_attributes(name: 'Test', email: "test@test.com", phone: "9189323232", reason: "Valid reason", message: "Valid message")
    end

    it "is not valid without a name" do
      contact_form = build :contact_form, name: nil
      expect(contact_form).to_not be_valid
    end

    it "is valid without a phone" do
      contact_form = build :contact_form, phone: nil
      expect(contact_form).to be_valid
    end

    it "is not valid without a email" do
      contact_form = build :contact_form, email: nil
      expect(contact_form).to_not be_valid
    end

    it "is valid without a reason" do
      contact_form = build :contact_form, reason: nil
      expect(contact_form).to be_valid
    end

    it "is valid without a message" do
      contact_form = build :contact_form, message: nil
      expect(contact_form).to be_valid
    end
  end

  it "requires an valid email" do
    contact_form = build :contact_form, email: "test@test.com"
    expect(contact_form).to be_valid
  end

  it "invalid email" do
    contact_form = build :contact_form, email: "test.test.com"
    expect(contact_form).to_not be_valid
  end

  describe '#headers' do
    it "should declare appropriate email headers" do
      contact_form = ContactForm.new
      expect(contact_form.headers).to include(:from, :reply_to, :subject, :to)
    end
  end

  describe '#reasons' do
    it "should return appropriate array" do
      expect(ContactForm.reasons).to eq(["REPORT_BUG_DROPDOWN", "REPORT_KOMMENT_DROPDOWN", "GIVE_HINT_DROPDOWN", "OTHER_DROP_DOWN"])
    end
  end
end
