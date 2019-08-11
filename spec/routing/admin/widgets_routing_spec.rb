describe Admin::WidgetsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/pcadmin/widgets")).to route_to("admin/widgets#index")
    end

    it "routes to #new" do
      expect(get("/pcadmin/widgets/new")).to route_to("admin/widgets#new")
    end

    it "routes to #edit" do
      expect(get("/pcadmin/widgets/1/edit")).to route_to("admin/widgets#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/pcadmin/widgets")).to route_to("admin/widgets#create")
    end

    it "routes to #update" do
      expect(put("/pcadmin/widgets/1")).to route_to("admin/widgets#update", :id => "1")
    end

  end
end
