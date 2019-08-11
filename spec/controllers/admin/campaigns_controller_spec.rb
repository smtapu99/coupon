module Admin
  describe CampaignsController do

    login_admin

    # This should return the minimal set of attributes required to create a valid
    # Campaign. As you add validations to Campaign, be sure to
    # update the return value of this method accordingly.
    def valid_attributes
      {
        'site_id'             => '1',
        'name'                => 'Campaign',
        'slug'                => 'campaign',
        'blog_feed_url'       => 'http://campaign.com/feed',
        'box_color'           => '#111',
        'coupon_filter_text'  => 'Filter Text',
        'h1_first_line'       => 'First Headline',
        'h1_second_line'      => 'Second Headline',
        'nav_title'           => 'Navigation Title',
        'text'                => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vero, vel.',
        'text_headline'       => 'Headline',
        'start_date'          => Time.zone.now.to_s(:db),
        'end_date'            => Time.zone.now.to_s(:db)
      }
    end

    # This should return the minimal set of attributes required to create an invalid
    # Campaign. As you add validations to Campaign, be sure to
    # update the return value of this method accordingly.
    def invalid_attributes
      {
        'site_id'             => '0',
        'name'                => nil,
        'slug'                => nil,
        'blog_feed_url'       => 'http://campaign.com/feed',
        'box_color'           => '#111',
        'coupon_filter_text'  => 'Filter Text',
        'h1_first_line'       => 'First Headline',
        'h1_second_line'      => 'Second Headline',
        'nav_title'           => 'Navigation Title',
        'text'                => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vero, vel.',
        'text_headline'       => 'Headline',
        'start_date'          => Time.zone.now.to_s(:db),
        'end_date'            => Time.zone.now.to_s(:db)
      }
    end

    def updated_attributes
      {
        'site_id'             => '2',
        'name'                => 'Updated Campaign',
        'slug'                => 'updated-campaign',
        'blog_feed_url'       => 'http://updated-campaign.com/feed',
        'box_color'           => '#111',
        'coupon_filter_text'  => 'Filter Text',
        'h1_first_line'       => 'First Headline',
        'h1_second_line'      => 'Second Headline',
        'nav_title'           => 'Navigation Title',
        'text'                => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vero, vel.',
        'text_headline'       => 'Headline',
        'start_date'          => Time.zone.now.to_s(:db),
        'end_date'            => Time.zone.now.to_s(:db)
      }
    end

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # CampaignsController. Be sure to keep this updated too.
    def valid_session
      {
        'warden.user.user.key' => session['warden.user.user.key']
      }
    end

    describe "GET index" do
      xit "assigns all campaigns as @campaigns" do
        campaign = Campaign.create! valid_attributes
        get :index, {}, valid_session
        assigns(:campaigns).should eq([campaign])
      end
    end

    # describe "GET show" do
    #   xit "assigns the requested campaign as @campaign" do
    #     campaign = Campaign.create! valid_attributes
    #     get :show, {:id => campaign.to_param}, valid_session
    #     assigns(:campaign).should eq(campaign)
    #   end
    # end

    describe "GET new" do
      xit "assigns a new campaign as @campaign" do
        get :new, {}, valid_session
        assigns(:campaign).should be_a_new(Campaign)
      end
    end

    describe "GET edit" do
      xit "assigns the requested campaign as @campaign" do
        campaign = Campaign.create! valid_attributes
        get :edit, {:id => campaign.to_param}, valid_session
        assigns(:campaign).should eq(campaign)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        xit "creates a new Campaign" do
          expect {
            post :create, {:campaign => valid_attributes}, valid_session
          }.to change(Campaign, :count).by(1)
        end

        xit "assigns a newly created campaign as @campaign" do
          post :create, {:campaign => valid_attributes}, valid_session
          assigns(:campaign).should be_a(Campaign)
          assigns(:campaign).should be_persisted
        end

        xit "redirects to the created campaign" do
          post :create, {:campaign => valid_attributes}, valid_session
          # response.should redirect_to(Campaign.last)
          response.should redirect_to(admin_campaigns_url)
        end
      end

      describe "with invalid params" do
        xit "assigns a newly created but unsaved campaign as @campaign" do
          # Trigger the behavior that occurs when invalid params are submitted
          Campaign.any_instance.stub(:save).and_return(false)
          post :create, {:campaign => invalid_attributes}, valid_session
          assigns(:campaign).should be_a_new(Campaign)
        end

        xit "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Campaign.any_instance.stub(:save).and_return(false)
          post :create, {:campaign => invalid_attributes}, valid_session
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        xit "updates the requested campaign" do
          campaign = Campaign.create! valid_attributes
          # Assuming there are no other campaigns in the database, this
          # specifies that the Campaign created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Campaign.any_instance.should_receive(:update).with(updated_attributes)
          put :update, {:id => campaign.to_param, :campaign => updated_attributes}, valid_session
        end

        xit "assigns the requested campaign as @campaign" do
          campaign = Campaign.create! valid_attributes
          put :update, {:id => campaign.to_param, :campaign => valid_attributes}, valid_session
          assigns(:campaign).should eq(campaign)
        end

        xit "redirects to the campaign" do
          campaign = Campaign.create! valid_attributes
          put :update, {:id => campaign.to_param, :campaign => valid_attributes}, valid_session
          response.should redirect_to(admin_campaigns_url)
        end
      end

      describe "with invalid params" do
        xit "assigns the campaign as @campaign" do
          campaign = Campaign.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Campaign.any_instance.stub(:save).and_return(false)
          put :update, {:id => campaign.to_param, :campaign => invalid_attributes}, valid_session
          assigns(:campaign).should eq(campaign)
        end

        xit "re-renders the 'edit' template" do
          campaign = Campaign.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Campaign.any_instance.stub(:save).and_return(false)
          put :update, {:id => campaign.to_param, :campaign => invalid_attributes}, valid_session
          response.should render_template("edit")
        end
      end
    end

    describe "export" do
      xit "export campaigns to csv" do
      end
    end

  end
end
