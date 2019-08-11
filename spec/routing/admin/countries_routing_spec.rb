
module Admin
  describe CountriesController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/countries")).to route_to("admin/countries#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/countries/new")).to route_to("admin/countries#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/countries/1/edit")).to route_to("admin/countries#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/countries")).to route_to("admin/countries#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/countries/1")).to route_to("admin/countries#update", :id => "1")
      end

    end
  end
end
