include ApplicationHelper

describe RobotsController do

  let!(:site) { create :site, hostname: 'test.host' }

  describe "GET 'index'" do

    before do
      Site.current = site
    end

    it "returns http success" do
      get :index
      expect(response.code).to eq("200")
    end

    it "shows the default rules" do
      get :index

      default_url_options[:host] = site.hostname

      expect(response.body).to include("User-agent: *")
      expect(response.body).to include("Disallow: #{URI.parse(dynamic_url_for('coupon', 'clickout', 1)).path.gsub!(/1/, '*')}")
      expect(response.body).to include("Disallow: /out/*")
      expect(response.body).to include("Disallow: /OUT/*")
      expect(response.body).to include("Disallow: /Out/*")
      expect(response.body).to include("Disallow: #{dynamic_url_for('search', 'index', only_path: true)}?*")
      expect(response.body).to include("Disallow: /*?*theme*")
      expect(response.body).to include("Disallow: /*?*Theme*")
      expect(response.body).to include("Disallow: /*?*PageSpeed*")
      expect(response.body).to include("Disallow: /*?*Pagespeed*")
      expect(response.body).to include("Disallow: /*?*pagespeed*")
      expect(response.body).to include("Disallow: /*?*Custom*")
      expect(response.body).to include("Disallow: /*?*custom*")
      expect(response.body).to include("Disallow: /*?*ModPagespeed*")
      expect(response.body).to include("Disallow: /*?*modpagespeed*")
      expect(response.body).to include("Disallow: /*?*Modpagespeed*")
      expect(response.body).to include("Disallow: /*?*modPagespeed*")
      expect(response.body).to include("Disallow: /*?*replytocom*")
      expect(response.body).to include("Disallow: /*?*shop_slug*")
      expect(response.body).to include("Disallow: /*?*parent_slug*")
      expect(response.body).to include("Disallow: /*?*slug*")
      expect(response.body).to include("Disallow: /ajaxs/*")
      expect(response.body).to include("Disallow: /deals/*")
      expect(response.body).to include("Sitemap: #{root_url.split('/').push('sitemap.xml').join('/')}")
    end

    context 'when robots_txt settings present' do
      let!(:setting) { create :setting, admin_rules: { robots_txt: "Disallow: /my-test/\n\n\n" }, site: site }
      it 'shows also extending rules and removes consecutive new lines' do
        get :index
        expect(response.body).to include("User-agent: *")
        expect(response.body).to include('Disallow: /my-test/')
        expect(response.body).to_not include("\n\n\n")
        expect(response.body).to include("Sitemap: #{root_url.split('/').push('sitemap.xml').join('/')}")
      end
    end
  end
end
