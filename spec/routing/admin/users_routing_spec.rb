module Admin
  describe UsersController do
    describe "routing" do

      it "routes to #index" do
        expect(get("/pcadmin/users")).to route_to("admin/users#index")
      end

      it "routes to #new" do
        expect(get("/pcadmin/users/new")).to route_to("admin/users#new")
      end

      it "routes to #edit" do
        expect(get("/pcadmin/users/1/edit")).to route_to("admin/users#edit", :id => "1")
      end

      it "routes to #create" do
        expect(post("/pcadmin/users")).to route_to("admin/users#create")
      end

      it "routes to #update" do
        expect(put("/pcadmin/users/1")).to route_to("admin/users#update", :id => "1")
      end

    end
  end
end
