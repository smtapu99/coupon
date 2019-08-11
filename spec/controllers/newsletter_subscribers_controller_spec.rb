describe NewsletterSubscribersController do
  let!(:site) { create :site, hostname: 'test.host' }
  let(:params) { { email: 'test@email.com' } }

  before do
    Site.current = site
    create(:setting_newsletter, site_id: site)
  end

  describe 'subscribe' do

    context 'when subscribed' do
      it do
        stub_request(:any, /api.mailchimp.com/).to_return(status: 200, body: '', headers: {})
        # stub_request(:any, %r{https:\/\/.*\.api\.mailchimp\.com.*}).to_return(status: 200, body: '', headers: {})
        post 'subscribe', params: params, xhr: true
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when email is empty ' do
      it do
        post 'subscribe', params: {}, xhr: true
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when request is not xhr' do
      it do
        post 'subscribe', xhr: false, params: params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
