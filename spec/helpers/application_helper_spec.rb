describe ApplicationHelper do
  let!(:site) { create :site, hostname: 'test.host' }

  context '.default_robots_txt' do
    before { Site.current = site }
    it 'returns the default robots' do
      defaults = helper.default_robots_txt
      expect(defaults).to include("User-agent: *")
      expect(defaults).to include("Disallow: #{URI.parse(dynamic_url_for('coupon', 'clickout', 1)).path.gsub!(/1/, '*')}")
      expect(defaults).to include("Disallow: /out/*")
      expect(defaults).to include("Disallow: /OUT/*")
      expect(defaults).to include("Disallow: /Out/*")
      expect(defaults).to include("Disallow: #{dynamic_url_for('search', 'index', only_path: true)}?*")
      expect(defaults).to include("Disallow: /*?*theme*")
      expect(defaults).to include("Disallow: /*?*Theme*")
      expect(defaults).to include("Disallow: /*?*PageSpeed*")
      expect(defaults).to include("Disallow: /*?*Pagespeed*")
      expect(defaults).to include("Disallow: /*?*pagespeed*")
      expect(defaults).to include("Disallow: /*?*Custom*")
      expect(defaults).to include("Disallow: /*?*custom*")
      expect(defaults).to include("Disallow: /*?*ModPagespeed*")
      expect(defaults).to include("Disallow: /*?*modpagespeed*")
      expect(defaults).to include("Disallow: /*?*Modpagespeed*")
      expect(defaults).to include("Disallow: /*?*modPagespeed*")
      expect(defaults).to include("Disallow: /*?*replytocom*")
      expect(defaults).to include("Disallow: /*?*shop_slug*")
      expect(defaults).to include("Disallow: /*?*parent_slug*")
      expect(defaults).to include("Disallow: /*?*slug*")
      expect(defaults).to include("Disallow: /ajaxs/*")
      expect(defaults).to include("Disallow: /deals/*")
    end
  end

  context '.newsletter_enabled?' do
    let!(:setting) { create :setting, site: site, newsletter: { newsletter_enabled: 1, mailchimp_api_key: 12345, mailchimp_list_id: 56789 } }
    subject { helper.newsletter_enabled? }
    before { Site.current = site }

    context 'when newsletter_enabled?' do
      context 'and mailchimp_api_key && mailchimp_list_id set' do
        it { is_expected.to eq(true) }
      end

      context 'and mailchimp_api_key blank?' do
        before { setting.update(newsletter: { mailchimp_api_key: nil }) }
        it { is_expected.to eq(false) }
      end
      context 'and mailchimp_list_id blank?' do
        before { setting.update(newsletter: { mailchimp_list_id: nil }) }
        it { is_expected.to eq(false) }
      end
    end
    context 'when not newsletter_enabled?' do
      before { setting.update(newsletter: { newsletter_enabled: 0 }) }
      it { is_expected.to eq(false) }
    end
  end

  context '.translate_from_file' do
    context 'when key exists' do
      subject { helper.translate_from_file('number.format.separator', locale: 'en-GB', default: ',') }
      it { is_expected.to eq('.') }
    end

    context 'when key doenst exist returns default' do
      subject { helper.translate_from_file('number.format.separator.doesnt-exist', locale: 'en-GB', default: ',') }
      it { is_expected.to eq(',') }
    end
  end

  context '.reduced_js_features?' do
    let!(:setting) { create :setting, publisher_site: { reduced_js_features: nil } }

    before { Site.current = site }

    it 'returns false if publisher_site.reduced_js_features isnt set' do
      expect(helper.reduced_js_features?).to eq(false)
    end

    it 'returns false if publisher_site.reduced_js_features is false' do
      setting.update(publisher_site: { reduced_js_features: '0' })
      expect(helper.reduced_js_features?).to eq(false)
    end

    it 'returns true if publisher_site.reduced_js_features is true' do
      setting.update(publisher_site: { reduced_js_features: '1' })
      expect(helper.reduced_js_features?).to eq(true)
    end
  end

  context '.dynamic_campaign_url_for' do
    let!(:campaign) { create :campaign, slug: 'my-slug' }

    before { Site.current = site }

    it 'without any options returns full url' do
      expect(helper.dynamic_campaign_url_for(campaign)).to eq('http://test.host/campaign/my-slug')
    end

    it 'with host opt' do
      expect(helper.dynamic_campaign_url_for(campaign, host: 'another.host')).to eq('http://another.host/campaign/my-slug')
    end

    it 'with protocol opt' do
      expect(helper.dynamic_campaign_url_for(campaign, protocol: 'ftp')).to eq('ftp://test.host/campaign/my-slug')
    end

    it 'with only_path opt' do
      expect(helper.dynamic_campaign_url_for(campaign, only_path: true)).to eq('/campaign/my-slug')
    end

    it 'root campaign returns root url' do
      campaign.update(is_root_campaign: true)
      expect(helper.dynamic_campaign_url_for(campaign)).to eq('http://test.host/my-slug')
    end

    it 'SEM campaign' do
      campaign.update(template: 'sem')
      expect(helper.dynamic_campaign_url_for(campaign)).to eq('http://test.host/deals/my-slug')
    end

    it 'campaign with parent_id' do
      parent = create(:campaign, slug: 'parent-slug')
      campaign.update(parent_id: parent.id)
      expect(helper.dynamic_campaign_url_for(campaign)).to eq('http://test.host/campaign/parent-slug/my-slug')
    end

    it 'campaign with shop_id' do
      shop = create(:shop, slug: 'shop-slug')
      campaign.update(shop_id: shop.id)
      expect(helper.dynamic_campaign_url_for(campaign)).to eq('http://test.host/shop/shop-slug/my-slug')
    end
  end

  context '.root_url' do
    subject { helper.root_url }
    before { Site.current = site }
    it { is_expected.to eq('http://test.host/') }
  end

  context '.root_path' do
    subject { helper.root_path }
    before { Site.current = site }
    it { is_expected.to eq('/') }
  end

  context '.is_shop?' do
    it 'returns false if page is other then shop page' do
      controller.params[:controller] = 'shops'
      controller.params[:action] = 'index'
      expect(helper.is_shop?).to eq(false)
    end
    it 'returns true if is shop page' do
      controller.params[:controller] = 'shops'
      controller.params[:action] = 'show'
      expect(helper.is_shop?).to eq(true)
    end
  end

  context '.is_home?' do
    it 'returns false if page is other then homepage' do
      controller.params[:controller] = 'shops'
      controller.params[:action] = 'index'
      expect(helper.is_home?).to eq(false)
    end
    it 'returns true if is home' do
      controller.params[:controller] = 'home'
      controller.params[:action] = 'index'
      expect(helper.is_home?).to eq(true)
    end
  end

  context '.cookie_url' do
    let!(:setting) { create :setting, admin_rules: { cookie_policy_url: '/example-page.html' } }

    before do
      RequestStore.store[:setting_current] = nil
      Site.current = site
    end

    it "returns cookie policy url if it's set" do
      expect(helper.cookie_url).to eq('/example-page.html')
    end

    it "returns nil if cookie policy url isn't set" do
      setting.update(admin_rules: { cookie_policy_url: nil })
      expect(helper.cookie_url).to eq(nil)
    end
  end
end
