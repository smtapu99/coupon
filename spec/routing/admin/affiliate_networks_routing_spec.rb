module Admin
  describe AffiliateNetworksController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/affiliate_networks")).to route_to("admin/affiliate_networks#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/affiliate_networks/new")).to route_to("admin/affiliate_networks#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/affiliate_networks/1/edit")).to route_to("admin/affiliate_networks#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/affiliate_networks")).to route_to("admin/affiliate_networks#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/affiliate_networks/1")).to route_to("admin/affiliate_networks#update", :id => "1")
      end

    end
  end
end
