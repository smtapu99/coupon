
module Admin
  describe CampaignsController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/campaigns")).to route_to("admin/campaigns#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/campaigns/new")).to route_to("admin/campaigns#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/campaigns/1/edit")).to route_to("admin/campaigns#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/campaigns")).to route_to("admin/campaigns#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/campaigns/1")).to route_to("admin/campaigns#update", :id => "1")
      end

    end
  end
end
