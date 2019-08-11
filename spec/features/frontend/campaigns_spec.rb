describe 'Campaigns' do

  include_context 'a basic frontend'
  include_context 'a campaign with widgets'

  let!(:shop) { FactoryGirl.create(:shop, site_id: site.id, status: 'active')}
  let!(:coupon) { FactoryGirl.create(:coupon, id: 1, site_id: site.id, status: 'active', shop: shop)}
  let!(:coupon2) { FactoryGirl.create(:coupon, id: 2, site_id: site.id, status: 'active', shop: shop)}
  let!(:coupon3) { FactoryGirl.create(:coupon, id: 3, site_id: site.id, status: 'active', shop: shop)}
  let!(:coupon4) { FactoryGirl.create(:coupon, id: 4, site_id: site.id, status: 'active', shop: shop)}

  context 'with' do

    xit 'status not active redirect to frontpage' do
      campaign.update_attributes(status: 'blocked')
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      expect(page.current_path).to eq '/'
    end

    xit 'start_date not reached dont show' do
      campaign.update_attributes(start_date: Time.zone.now + 1.day)
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      expect(page.current_path).to eq '/'
    end

    xit 'end_date in past still are accessible' do
      campaign.update_attributes(end_date: Time.zone.now - 1.day)
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      expect(page.status_code).to eq 200
    end

    xit 'end_date in past dont show navigation' do
      # they show correctly
      campaign.update_attributes(status: 'active')
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      expect(page).to have_css('.navbar .colored-nav')

      # and disappear on end_date reached
      campaign.update_attributes(status: 'active', end_date: Time.zone.now - 1.day)
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      expect(page).to have_css('.navbar .colored-nav')
    end

    xit 'foreign site_id dont show' do
      campaign.update_column(:site_id, 99)
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      expect(page.current_path).to eq '/'
    end

  end

  context 'show' do

    subject(:content) do
      User.current = User.first

      campaign.coupons = Coupon.all

      campaign.update_attributes(
        status: 'active',
        shop_id: nil,
        name: 'my_name',
        tag_string: tag.word,
        coupon_filter_text: 'coupon_filter_text',
        h1_first_line: 'my_h1_first_line',
        h1_second_line: 'my_h1_second_line',
        nav_title: 'my_nav_title',
        text_headline: 'text_headline',
        box_color: 'gold',
        text: 'text',
        html_document: FactoryGirl.create(:html_document,
          meta_robots: 'my_meta_robots',
          meta_keywords: 'my_meta_keywords',
          meta_description: 'my_meta_description',
          meta_title: 'my_meta_title'
        )
      )
      visit send("campaign_show_#{site.id}_path", slug: campaign.slug)
      return page
    end

    context 'shows the right widgets' do

      context 'in main area' do
        xit { expect(content.find('.campaign-widgets-main')).to have_content campaign_widget_newsletter.title }
        xit { expect(content.find('.campaign-widgets-main')).to have_content campaign_widget_category.title }
      end

      context 'in sidebar area' do
        xit { expect(content.find('#sidebar')).to have_content campaign_widget_newsletter.title }
      end
    end

    xit 'shows the right breadcrumbs' do
      expect(content.find('.breadcrumbs')).to have_content(campaign.name)
    end

    it { expect(send("campaign_show_#{site.id}_path", slug: campaign.slug)).to eq("/campaign/#{campaign.slug}")} # shop_id
    it { expect(send("campaign_show_#{site.id}_path", slug: campaign.slug)).to eq("/campaign/#{campaign.slug}") } # slug
    xit { expect(content).to have_selector('.coupons-list li', count: 4) } #tag_string
    xit { expect(content.find('#sidebar .box-header h2')).to have_content(campaign.coupon_filter_text) } # coupon_filter_text
    xit { expect(content.find('h1')).to have_content campaign.h1_first_line } # h1_first_line
    xit { expect(content.find('h1')).to have_content campaign.h1_second_line } # h1_second_line
    xit { expect(content).to have_css('.navbar .colored-nav.bg-gold')} # nav_color
    xit { expect(content.find('.navbar')).to have_content(campaign.nav_title)} # nav_title
    xit { expect(content.find('.box-about h2')).to have_content campaign.text_headline} # seo_text_headline
    xit { expect(content.find('.box-about .box-content')).to have_content campaign.text } # seo_text
    xit { expect(content).to have_meta :robots, campaign.html_document_meta_robots} # meta_robots
    xit { expect(content).to have_meta :keywords, campaign.html_document_meta_keywords} # meta_keywords
    xit { expect(content).to have_meta :description, campaign.html_document_meta_description} # meta_description
    xit { expect(content).to have_title campaign.html_document_meta_title} # meta_title

    context 'subpage' do

      before do
        campaign.update_attributes(shop_id: shop.id)
        visit send("shop_campaign_#{site.id}_path", slug: campaign.slug, shop_slug: shop.slug)
      end

      xit 'changes the route' do
        expect(page.status_code).to eq 200
      end

      xit 'shows the correct breadcrumbs' do
        expect(page.find('.breadcrumbs')).to have_content(campaign.shop.title)
        expect(page.find('.breadcrumbs')).to have_content(campaign.name)
      end

    end

  end

end
