
module Admin
  describe ShopsController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/shops")).to route_to("admin/shops#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/shops/new")).to route_to("admin/shops#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/shops/1/edit")).to route_to("admin/shops#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/shops")).to route_to("admin/shops#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/shops/1")).to route_to("admin/shops#update", :id => "1")
      end

    end
  end
end
