
module Admin
  describe CouponsController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/coupons")).to route_to("admin/coupons#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/coupons/new")).to route_to("admin/coupons#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/coupons/1/edit")).to route_to("admin/coupons#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/coupons")).to route_to("admin/coupons#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/coupons/1")).to route_to("admin/coupons#update", :id => "1")
      end

    end
  end
end
