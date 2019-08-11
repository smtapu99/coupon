module Admin
  describe StaticPagesController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/static_pages")).to route_to("admin/static_pages#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/static_pages/new")).to route_to("admin/static_pages#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/static_pages/1/edit")).to route_to("admin/static_pages#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/static_pages")).to route_to("admin/static_pages#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/static_pages/1")).to route_to("admin/static_pages#update", :id => "1")
      end
    end
  end
end
