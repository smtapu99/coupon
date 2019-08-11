describe Admin::BaseController do
  context '.allowed_site_ids' do
    let(:site) { create(:site) }

    it 'returns the users sites' do
      User.current = FactoryGirl.create(:freelancer, sites: [site])
      expect(controller.instance_eval{ allowed_site_ids }).to eq([site.id])
    end
  end
end
