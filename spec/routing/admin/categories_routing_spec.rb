
module Admin
  describe CategoriesController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/categories")).to route_to("admin/categories#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/categories/new")).to route_to("admin/categories#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/categories/1/edit")).to route_to("admin/categories#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/categories")).to route_to("admin/categories#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/categories/1")).to route_to("admin/categories#update", :id => "1")
      end

    end
  end
end
