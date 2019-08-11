describe Admin::GlobalsController do
  let!(:site) { create :site, hostname: 'test.host' }

  login_admin

  before do
    Site.current = site
  end

  describe 'POST update_shop_mapping' do
    let!(:global) { create :global }
    let!(:country) { create :country }

    context 'when mapping exists' do
      let!(:shop_mapping) { create :global_shop_mapping, country: country, global: global }

      it 'and is valid - updates existing mapping and returns 201 "Created"' do
        post :update_shop_mapping, params: { shop_mapping: { global_id: global.id, country_id: country.id, url_home: 'http://test.de' } }
        expect(Global::ShopMapping.last.url_home).to eq('http://test.de')
        expect(JSON.parse(response.body)).to include(Global::ShopMapping.last.attributes)
        expect(response.code).to eq('201')
      end

      it 'and is invalid - returns validation errors and 422 "Unprocessable Entity"' do
        post :update_shop_mapping, params: { shop_mapping: { global_id: global.id, country_id: country.id, url_home: 'wrong url' } }
        expect(response.body).to eq({ url_home: ['must be a valid URL'] }.to_json)
        expect(response.code).to eq('422')
      end
    end

    context 'when mapping doesnt exist' do
      it 'and is valid - creates it and returns 201 "Created"' do
        post :update_shop_mapping, params: { shop_mapping: { global_id: global.id, country_id: country.id, url_home: 'http://test.de' } }
        expect(Global::ShopMapping.last.url_home).to eq('http://test.de')
        expect(response.code).to eq('201')
      end
    end
  end
end
