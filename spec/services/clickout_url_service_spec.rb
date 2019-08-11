describe ClickoutUrlService do

  def has_all_params? coupon, clickrefs=nil
    if clickrefs.present?
      url = ClickoutUrlService.new(coupon, clickrefs).url
      expect(has_params?(url, default_except_existing_params(coupon).merge(clickrefs))).to be true
    else
      url = ClickoutUrlService.new(coupon).url
      expect(has_params?(url, default_except_existing_params(coupon))).to be true
    end
  end

  def removes_unwanted_params? coupon, unwanted=nil
    expect(has_params?(ClickoutUrlService.new(coupon, unwanted).url, unwanted)).to be false
  end

  def default_except_existing_params coupon
    params = {
      'clickref' => 'pctracking',
      'clickref2' => coupon.site.hostname,
      'clickref5' => coupon.is_exclusive? ? 'exclusive deal' :  coupon.coupon_type
    }.except(*get_params(coupon.url).keys)
  end

  def has_params? url, params={}
    url_params = get_params(url)
    url_params.values_at(*params.keys).map(&:to_s) == params.values.map(&:to_s)
  end

  def get_params url
    Rack::Utils.parse_nested_query(Addressable::URI.parse(url).query)
  end

  let!(:site) { create :site, hostname: 'test.host' }

  context 'when initialized with a non dynamic' do

    let!(:affiliate_network) { create :affiliate_network, slug: 'my_slug' }
    let!(:coupon) { create :coupon, site: site, affiliate_network: affiliate_network, url: 'http://url.de?ref1=mt_tracking&ref2=pc_tracking&ref3=pctracking' }

    context 'broken coupon' do
      let!(:broken_coupon) { create :coupon, url: 'http://url1.de' }

      it 'raises a ClickoutUrlServiceError if url is blank' do
        broken_coupon.url = nil
        expect{ClickoutUrlService.new(broken_coupon)}.to raise_error(ClickoutUrlServiceError)
      end

      it 'returns url even if affiliate_network is blank' do
        broken_coupon.affiliate_network_id = nil
        expect(ClickoutUrlService.new(broken_coupon).url).to eq(broken_coupon.url)
      end
    end

    context 'valid coupon' do

      before do
        @service = ClickoutUrlService.new(coupon)
      end

      it 'gives access to interface' do
        expect(@service.url).to eq(coupon.url)
      end

      it 'replaces tracking_click' do
        expect(@service.replace_tracking_click("123456")).to eq('http://url.de?ref1=123456&ref2=123456&ref3=123456')
      end

      it 'replaces tracking_click also with integer input' do
        expect(@service.replace_tracking_click(123456)).to eq('http://url.de?ref1=123456&ref2=123456&ref3=123456')
      end
    end
  end


  context 'DigidipUrl' do
    let!(:coupon) { create :coupon, site: site, url: 'http://www.digidip.com' }

    context 'ads' do
      subject { ClickoutUrlService.new(coupon).url }
      context 'ref' do
        it { is_expected.to include("ref=pctracking") }
      end

      context 'ppref' do
        it { is_expected.to include("ppref=https%3A%2F%2Ftest.host") }

        context 'when site is multisite' do
          before { site.update(is_multisite: true, subdir_name: '/test') }
          it { is_expected.to include("ppref=https%3A%2F%2Ftest.host%2Ftest") }
        end
      end

      context 'nothing if param is already set' do
        before { coupon.update(url: 'http://www.digidip.com?ref=myref&ppref=myppref') }
        it { is_expected.to include("ppref=myppref") }
        it { is_expected.to include("ref=myref") }
      end
    end
  end


  context 'awin coupon' do

    let!(:awin) { create :affiliate_network, slug: 'awin' }
    let!(:awin_coupon) { create :coupon, site: site, affiliate_network: awin, url: 'http://www.awin1.de?awin=123', coupon_type: :coupon, code: '123' }
    let!(:awin_offer) { create :coupon, site: site, affiliate_network: awin, url: 'http://www.awin1.de?awin=123', coupon_type: :offer }
    let!(:awin_coupon_deeplink) { create :coupon, site: site, affiliate_network: awin, url: 'http://www.awin1.de?awin=123&p=https%3A%2F%2Fdeeplink.de', coupon_type: :coupon, code: '123' }
    let!(:awin_coupon_no_query) { create :coupon, site: site, affiliate_network: awin, url: 'http://www.awin1.de', coupon_type: :coupon, code: '123' }
    let!(:awin_coupon_clickref) { create :coupon, site: site, affiliate_network: awin, url: 'http://www.awin1.com/cread.php?&awinmid=7529&awinaffid=261951&clickref=dont_replace&p=http%3A%2F%2Fwww.avianca.com%2Fes-cl%2F', coupon_type: :coupon, code: '123' }
    let!(:manual_clickrefs) {
      {
        'clickref3' => 'campaign',
        'clickref4' => 'source',
        'clickref6' => 'sem',
      }
    }

    context 'when site is multisite' do
      before { site.update(is_multisite: true, subdir_name: '/test') }
      subject { ClickoutUrlService.new(awin_coupon).url }
      it { is_expected.to include('clickref2=test.host%2Ftest') }
    end

    context 'without manual clickrefs' do
      it 'and without query params shows default params' do
        has_all_params?(awin_coupon_no_query)
      end

      it 'and with existing query params shows default params' do
        has_all_params?(awin_coupon)
      end
    end

    context 'with manual clickrefs' do
      it 'and without query params' do
        has_all_params?(awin_coupon_no_query, {'clickref3' => 'campaign','clickref4' => 'source'})
      end

      it 'and with existing query params' do
        has_all_params?(awin_coupon, {'clickref3' => 'campaign','clickref4' => 'source'})
      end

      it 'removes wrong_ref clickrefs' do
        removes_unwanted_params?(awin_coupon, {'wrong_ref' => 'campaign'})
      end

      it 'also works for exclusive deals' do
        awin_coupon.is_exclusive = true
        has_all_params?(awin_coupon, {'clickref5' => 'exclusive deal'})
      end

      context 'and deeplink' do
        it 'moves deeplink to last position' do
          params = get_params(ClickoutUrlService.new(awin_coupon_deeplink, manual_clickrefs).url)
          expect(params.keys.map(&:to_s).last).to eq('p')
          expect(params.values.map(&:to_s).last).to eq('https://deeplink.de')
        end
      end
    end

    context 'with exising clickrefs in the url' do
      it 'does not overwrite them' do
        has_all_params?(awin_coupon_clickref, {'clickref' => 'dont_replace'})
      end
    end

    it 'works with real coupon urls' do
      urls = [
        "https://www.awin1.com/cread.php?awinmid=11128&awinaffid=413377pctracking&p=",
        "http://www.awin1.com/cread.php?awinmid=7529&awinaffid=261951&p=http%3A%2F%2Fwww.avianca.com%2Fes-cl%2F",
        "http://www.awin1.com/cread.php?awinaffid=413377&awinmid=10247&clickref=pctracking&clickref2=www.newsweek.pl&p=http%3A%2F%2Fwww.zooplus.pl%2F",
        "http://www.awin1.com/cread.php?awinaffid=413377&awinmid=10247&clickref=pctracking&clickref2=www.newsweek.pl&p=http%3A%2F%2Fwww.zooplus.pl%2F",
        "https://www.awin1.com/cread.php?clickref2=cupon.es",
        "https://www.awin1.com/cread.php?awinmid=11122&awinaffid=413377&clickref=pctracking&clickref2=cupon.es",
        "https://www.awin1.com/cread.php?awinmid=8015&awinaffid=413377&clickref=pctracking&clickref2=www.newsweek.pl&p=https%3A%2F%2Fanswear.com%2Fp%2Fona-4-k.html",
        "http://www.awin1.com/cread.php?awinaffid=413377&awinmid=10257&clickref=pctracking&clickref2=kupon.pl&p=https%3A%2F%2Festyl.pl%2F",
        "http://www.awin1.com/cread.php?awinaffid=413377&awinmid=10257&clickref2=kupon.pl&p=https%3A%2F%2Festyl.pl%2F",
        "https://www.awin1.com/cread.php?awinmid=8015&awinaffid=413377&clickref=pctracking&clickref2=www.kupon.pl&p=https%3A%2F%2Fanswear.com%2Fp%2Fona-4-k.html",
        "https://www.awin1.com/cread.php?awinmid=11122&awinaffid=413377&clickref=pctracking&clickref2=cupon.es",
        "http://www.awin1.com/cread.php?awinaffid=413377&awinmid=10230&&clickref2=kupon.pl&p=http%3A%2F%2Fwww.laredoute.pl%2F",
        "https://www.awin1.com/cread.php?awinmid=11054&awinaffid=413377&clickref=pctracking",
        "https://www.awin1.com/cread.php?awinmid=10895&awinaffid=413377&clickref=pctracking&clickref2=www.newsweek.pl&p=https%3A%2F%2Fwww.butyjana.pl%2F",
        "http://www.awin1.com/cread.php?awinmid=3674&awinaffid=478081&clickref=pctracking&p=https://ad.doubleclick.net/ddm/clk/410153777;210449469;j?https://www.talktalk.co.uk/shop/broadband/mk/?portalid=aff-longtail&utm_campaign=newacq_broadband&utm_medium=affiliate&utm_source=longtail&utm_content=listing&portalid2=new&awin_id=478081"
      ]
      urls.each do |url|
        awin_coupon.url = url
        has_all_params?(awin_coupon)
      end
    end
  end
end

