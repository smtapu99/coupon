
module Admin
  describe SitesController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/sites")).to route_to("admin/sites#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/sites/new")).to route_to("admin/sites#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/sites/1/edit")).to route_to("admin/sites#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/sites")).to route_to("admin/sites#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/sites/1")).to route_to("admin/sites#update", :id => "1")
      end

    end
  end
end
