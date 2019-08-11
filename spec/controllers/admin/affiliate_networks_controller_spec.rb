module Admin
  describe AffiliateNetworksController do

    login_admin

    # This should return the minimal set of attributes required to create a valid
    # AffiliateNetwork. As you add validations to AffiliateNetwork, be sure to
    # update the return value of this method accordingly.
    def valid_attributes
      {
        'name' => 'Affiliate Network',
        'slug' => 'affiliate-network',
        'status' => AffiliateNetwork.statuses[:active]
      }
    end

    # This should return the minimal set of attributes required to create an invalid
    # AffiliateNetwork. As you add validations to AffiliateNetwork, be sure to
    # update the return value of this method accordingly.
    def invalid_attributes
      {
        'name' => 'Invalid Affiliate Network 1',
        'slug' => false,
        'status' => 'invalid_status'
      }
    end

    def updated_attributes
      {
        'name' => 'Updated Affiliate Network',
        'slug' => 'updated-affiliate-network',
        'status' => AffiliateNetwork.statuses[:blocked]
      }
    end

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # AffiliateNetworksController. Be sure to keep this updated too.
    def valid_session
      {
        'warden.user.user.key' => session['warden.user.user.key']
      }
    end

    describe "GET index" do
      xit "assigns all affiliate_networks as @affiliate_networks" do
        affiliate_network = AffiliateNetwork.create! valid_attributes
        get :index, {}, valid_session
        assigns(:affiliate_networks).should eq([affiliate_network])
      end
    end

    describe "GET new" do
      xit "assigns a new affiliate_network as @affiliate_network" do
        get :new, {}, valid_session
        assigns(:affiliate_network).should be_a_new(AffiliateNetwork)
      end
    end

    describe "GET edit" do
      xit "assigns the requested affiliate_network as @affiliate_network" do
        affiliate_network = AffiliateNetwork.create! valid_attributes
        get :edit, {:id => affiliate_network.to_param}, valid_session
        assigns(:affiliate_network).should eq(affiliate_network)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        xit "creates a new AffiliateNetwork" do
          expect {
            post :create, {:affiliate_network => valid_attributes}, valid_session
          }.to change(AffiliateNetwork, :count).by(1)
        end

        xit "assigns a newly created affiliate_network as @affiliate_network" do
          post :create, {:affiliate_network => valid_attributes}, valid_session
          assigns(:affiliate_network).should be_a(AffiliateNetwork)
          assigns(:affiliate_network).should be_persisted
        end

        xit "redirects to the created affiliate_network" do
          post :create, {:affiliate_network => valid_attributes}, valid_session
          # response.should redirect_to(AffiliateNetwork.last)
          response.should redirect_to(admin_affiliate_networks_url)
        end
      end

      describe "with invalid params" do
        xit "assigns a newly created but unsaved affiliate_network as @affiliate_network" do
          # Trigger the behavior that occurs when invalid params are submitted
          AffiliateNetwork.any_instance.stub(:save).and_return(false)
          post :create, {:affiliate_network => invalid_attributes}, valid_session
          assigns(:affiliate_network).should be_a_new(AffiliateNetwork)
        end

        xit "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          AffiliateNetwork.any_instance.stub(:save).and_return(false)
          post :create, {:affiliate_network => invalid_attributes}, valid_session
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        xit "updates the requested affiliate_network" do
          affiliate_network = AffiliateNetwork.create! valid_attributes
          # Assuming there are no other affiliate_networks in the database, this
          # specifies that the AffiliateNetwork created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          AffiliateNetwork.any_instance.should_receive(:update).with(updated_attributes)
          put :update, {:id => affiliate_network.to_param, :affiliate_network => updated_attributes}, valid_session
        end

        xit "assigns the requested affiliate_network as @affiliate_network" do
          affiliate_network = AffiliateNetwork.create! valid_attributes
          put :update, {:id => affiliate_network.to_param, :affiliate_network => valid_attributes}, valid_session
          assigns(:affiliate_network).should eq(affiliate_network)
        end

        xit "redirects to the affiliate_network" do
          affiliate_network = AffiliateNetwork.create! valid_attributes
          put :update, {:id => affiliate_network.to_param, :affiliate_network => valid_attributes}, valid_session
          response.should redirect_to(admin_affiliate_networks_url)
        end
      end

      describe "with invalid params" do
        xit "assigns the affiliate_network as @affiliate_network" do
          affiliate_network = AffiliateNetwork.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          AffiliateNetwork.any_instance.stub(:save).and_return(false)
          put :update, {:id => affiliate_network.to_param, :affiliate_network => invalid_attributes}, valid_session
          assigns(:affiliate_network).should eq(affiliate_network)
        end

        xit "re-renders the 'edit' template" do
          affiliate_network = AffiliateNetwork.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          AffiliateNetwork.any_instance.stub(:save).and_return(false)
          put :update, {:id => affiliate_network.to_param, :affiliate_network => invalid_attributes}, valid_session
          response.should render_template("edit")
        end
      end
    end

  end
end

