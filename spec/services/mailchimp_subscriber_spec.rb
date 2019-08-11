describe MailchimpSubscriber do
  let(:site) { create :site }
  let(:email) { 'email@email.com' }
  let(:request_body) do
    {
      email_address: email,
      merge_fields: { GENERAL: 'all' },
      status: 'pending'
    }
  end

  def stub_requests(existing_member = false)
    stub_request(:put, "https://us1.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}")
      .with(body: MultiJson.dump(request_body))
      .to_return(status: 200, body: MultiJson.dump(request_body))

    if existing_member
      stub_request(:get, "https://us1.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}")
        .to_return(status: 200, body: MultiJson.dump(request_body.merge(status: 'subscribed')))
    else
      stub_request(:get, "https://us1.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}")
        .to_return(status: 200)
    end
  end

  it 'raises an error if list_id and api_key settings are missing' do
    expect{MailchimpSubscriber.new(email, site)}.to raise_error(Gibbon::GibbonError)
  end

  context 'when settings set' do
    let!(:setting) { create(:setting_newsletter, site_id: site.id) }
    let(:api_key) { setting.newsletter.mailchimp_api_key }
    let(:list_id) { setting.newsletter.mailchimp_list_id }
    let(:member_id) { Digest::MD5.hexdigest(email) }

    it 'returns an instance' do
      stub_requests

      expect(MailchimpSubscriber.new(email, site)).to be_a(MailchimpSubscriber)
    end

    context '.subscribe' do
      it 'creates a member' do
        stub_requests

        # subscribe
        sub = MailchimpSubscriber.new(email, site)
        expect(sub.status).to eq(nil)
        sub.subscribe(GENERAL: 'all')

        # updates status
        expect(sub.status).to eq('pending')
        expect(sub.new?).to eq(true)
      end
    end

    context '.new?' do
      it 'returns true if member is new' do
        stub_requests

        sub = MailchimpSubscriber.new(email, site)
        # status is nil
        expect(sub.new?).to eq(true)
      end

      it 'returns false if member is exists' do
        stub_requests(true)

        sub = MailchimpSubscriber.new(email, site)
        expect(sub.new?).to eq(false)
      end
    end

    context '.reload_member' do
      it 'reloads the member' do
        # subscribe a new member
        stub_requests
        sub = MailchimpSubscriber.new(email, site)
        sub.subscribe(GENERAL: 'all')
        expect(sub.status).to eq('pending')

        # reload it - assuming member confirmed in the meantime
        stub_requests(true)
        sub.reload_member
        expect(sub.status).to eq('subscribed')
      end
    end

    context 'calls to' do
      before { stub_requests }

      it 'site return the site' do
        expect(MailchimpSubscriber.new(email, site).site).to eq(site)
      end

      it 'email return the email' do
        expect(MailchimpSubscriber.new(email, site).email).to eq(email)
      end

      context 'member' do
        it 'returns nil unless member present' do
          expect(MailchimpSubscriber.new(email, site).member).to eq(nil)
        end

        it 'returns a member' do
          sub = MailchimpSubscriber.new(email, site)
          sub.subscribe(GENERAL: 'all')
          expect(sub.member).to be_a(Gibbon::Response)
        end
      end

      context 'error and error?' do
        it 'fail unless error present' do
          expect(MailchimpSubscriber.new(email, site).error).to eq(nil)
          expect(MailchimpSubscriber.new(email, site).error?).to eq(false)
        end

        context 'with a wrong email' do
          let(:email) { 'wrongemail' }

          it 'succeed' do
            # stub failing request
            stub_request(:put, "https://us1.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}")
              .with(body: MultiJson.dump(request_body))
              .to_raise(Gibbon::MailChimpError)

            sub = MailchimpSubscriber.new(email, site)
            expect(sub.error?).to eq(false)

            sub.subscribe(GENERAL: 'all')
            expect(sub.error).to be_a(Gibbon::MailChimpError)

            expect(sub.error?).to eq(true)
          end
        end
      end
    end
  end
end
