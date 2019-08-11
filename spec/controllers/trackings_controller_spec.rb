describe TrackingsController, type: :controller do
  let!(:site) { create :site, hostname: 'test.host' }
  let(:query_params) { { query_string_params: { gclid: '74152', campaign_id: 52, adgroup_id: 85, keyword: 'bumsegal' } } }

  context 'POST "set"' do
    context 'when new user' do
      it 'should respond with status code :created (201)' do
        post :set, params: query_params, xhr: true
        expect(response).to have_http_status(:created)
      end

      it 'should create new tracking_user' do
        expect{ post :set, params: query_params, xhr: true }.to change { TrackingUser.count }.by(1)
      end

      it 'should create new tracking click in' do
        expect{ post :set, params: query_params, xhr: true }.to change { TrackingClick.click_in.count }.by(1)
      end

      it 'should set cookies[subIdTracking]' do
        post :set, params: query_params, xhr: true
        expect(response.cookies['subIdTracking']).to eq(TrackingUser.find(JSON.parse(response.body)['tracking_user_id']).uniqid)
      end

      it 'should set session[subIdTracking] ' do
        post :set, params: query_params, xhr: true
        expect(session['subIdTracking']).to eq(TrackingUser.find(JSON.parse(response.body)['tracking_user_id']).uniqid)
      end

      it 'should set CampaignTrackingData' do
        post :set, params: query_params, xhr: true
        expect(CampaignTrackingData.last.tracking_click.tracking_user_id).to eq(JSON.parse(response.body)['tracking_user_id'])
      end
    end

    context 'when user has subIdTracking' do
      let!(:tracking_user) { create :tracking_user }
      before { cookies['subIdTracking'] = tracking_user.uniqid }

      it do
        post :set, params: query_params, xhr: true
        expect(response).to have_http_status(:created)
      end

      it 'should return existing tracking_user' do
        expect{ post :set, params: query_params, xhr: true }.to change { TrackingUser.count }.by(0)
        expect(JSON.parse(response.body)['tracking_user_id']).to eq(tracking_user.id)
      end

      it 'should create new tracking click in' do
        expect{ post :set, params: query_params, xhr: true }.to change { TrackingClick.click_in.count }.by(1)
      end

      it 'should set cookies[subIdTracking]' do
        post :set, params: query_params, xhr: true
        expect(response.cookies['subIdTracking']).to eq(tracking_user.uniqid)
      end

      it 'should set session[subIdTracking] ' do
        post :set, params: query_params, xhr: true
        expect(session['subIdTracking']).to eq(tracking_user.uniqid)
      end

      it 'should set CampaignTrackingData' do
        post :set, params: query_params, xhr: true
        expect(CampaignTrackingData.last.tracking_click.tracking_user_id).to eq(tracking_user.id)
      end
    end

    context 'when request not xhr' do
      it 'should respond with status code :forbidden (403)' do
        post :set, params: query_params, xhr: false
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when request has Fastly geo headers' do
      let(:fastly_headers) { {'X-Geo-Country-Name': 'CountryName', 'X-Geo-City': 'CityName', 'X-Geo-Postcode': '00000'}.with_indifferent_access }
      it 'should create tracking user with Fastly geo data' do
        request.headers.merge!(fastly_headers)
        post :set, params: query_params, xhr: true

        tracking_user = TrackingUser.find(JSON.parse(response.body)['tracking_user_id'])

        expect(tracking_user.country).to eq(fastly_headers['X-Geo-Country-Name'])
        expect(tracking_user.city).to eq(fastly_headers['X-Geo-City'])
        expect(tracking_user.postal_code).to eq(fastly_headers['X-Geo-Postcode'])
      end
    end

    context 'when request has no geo headers' do
      it 'should create tracking user without geo data' do
        post :set, params: query_params, xhr: true

        tracking_user = TrackingUser.find(JSON.parse(response.body)['tracking_user_id'])

        expect(tracking_user.country).to be_nil
        expect(tracking_user.city).to be_nil
        expect(tracking_user.postal_code).to be_nil
      end
    end
  end
end
