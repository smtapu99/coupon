describe StructuredDataHelper do

  let(:host) { 'test.host' }
  let(:url) { (Frontend::Application.config.force_ssl ? 'https' : 'http')+ '://' + host }
  let!(:site) { create :site, hostname: host }
  let!(:shop) { create :shop, site: site, total_votes: 10, total_stars: 30 }

  def base_structured_data
    {
      '@context'=>'http://schema.org',
      '@graph'=> [
        {
          '@type'=>'WebSite',
          'url'=>url+'/',
          'potentialAction'=> {
            '@type'=>'SearchAction',
            'target'=>url+'/search?query={query}',
            'query-input'=>'required name=query'
          }
        },
        {
          '@type'=>'WebPage',
          'url'=>url
        }
      ]
    }
  end

  def webpage_element
    {
      '@type' => 'WebPage',
      'url' => url,
      'description' => 'my description',
      'name' => 'my title',
      'AggregateRating' => {
        '@type' => 'AggregateRating',
        'name' => shop.title,
        'ratingValue' => shop.formatted_rating,
        'reviewCount' => shop.total_votes,
        'worstRating' => 0,
        'bestRating' => 5
      },
      'primaryImageOfPage' => {
        '@type' => 'ImageObject',
        'contentUrl' => 'https://social-image.png'
      }
    }
  end

  def site_navigation_element(opts={})
    {
      '@type' => 'SiteNavigationElement',
      '@id' => '#navigation',
      'name' => opts[:name],
      'url' => opts[:url]
    }
  end

  def breadcrumbs_element(opts={})
    {
      '@type' => 'BreadcrumbList',
      'itemListElement' => [
        {
          '@type' => 'ListItem',
          'position' => opts[:position],
          'item' => {
            '@id' => opts[:item],
            'name' => opts[:name]
          }
        }
      ]
    }
  end

  before { Site.current = site }

  context '::site_navigation_element' do
    it 'adds site_navigation_element to strucutured data json' do
      helper.site_navigation_element(name: 'Test 1', url: 'http://test-1.de')
      expect(helper.send(:structured_data_hash)['@graph']).to include(site_navigation_element(name: 'Test 1', url: 'http://test-1.de'))
    end
  end

  context '::breadcrumbs_element' do
    it 'adds breadcrumbs_element to strucutured data json' do
      helper.breadcrumbs_element(position: '1', item: 'http://test-1.de', name: 'Test 1')

      expect(helper.send(:structured_data_hash)['@graph']).to include(breadcrumbs_element(position: '1', item: 'http://test-1.de', name: 'Test 1'))
    end
  end

  context '::structured_data_hash' do

    it 'returns the base structured data' do
      expect(helper.send(:structured_data_hash)).to include(base_structured_data)
    end

    describe 'webpage_element' do
      let!(:site_settings) { create :setting_site, site: site }

      before do
        controller.params[:controller] = 'shops'
        controller.params[:action] = 'show'

        helper.content_for :social_image, 'https://social-image.png'
        helper.content_for :description, 'my description'
        helper.content_for :title, 'my title'

        @shop = shop
      end

      context 'valid' do
        subject { helper.send(:structured_data_hash)['@graph'] }

        it { is_expected.to include(webpage_element) }
      end

      context 'when hide_star_rating < shop rating' do
        let(:hide_star_rating) { site_settings.publisher_site.hide_star_rating }

        subject { helper.send(:webpage_base) }

        it { is_expected.to have_key('AggregateRating') }
        it { expect( shop.rating.to_f ).to be >= hide_star_rating }
      end

      context 'when hide_star_rating is string' do
        let(:hide_star_rating) { 1 }

        before do
          site_settings.publisher_site.hide_star_rating = hide_star_rating.to_s
          site_settings.save
        end

        subject { helper.send(:webpage_base) }

        it { is_expected.to have_key('AggregateRating') }
        it { expect( shop.rating.to_f ).to be >= hide_star_rating }
      end

      context 'when hide_star_rating is nil' do
        let(:default_hide_star_rating) { 2.5 }

        before do
          site_settings.publisher_site.hide_star_rating = nil
          site_settings.save
        end

        subject { helper.send(:webpage_base) }

        it { is_expected.to have_key('AggregateRating') }
        it { expect( shop.rating.to_f ).to be >= default_hide_star_rating }
      end

      context 'when hide_star_rating > shop rating' do
        let(:hide_star_rating) { 3.1 }
        before do
          site_settings.publisher_site.hide_star_rating = hide_star_rating
          site_settings.save
        end

        subject { helper.send(:webpage_base) }

        it { is_expected.not_to have_key('AggregateRating') }
        it { expect( shop.rating.to_f ).to be <= hide_star_rating }
      end
    end

    context 'when shop has' do
      before do
        @shop = shop
        controller.params[:controller] = 'shops'
        controller.params[:action] = 'show'
      end

      context 'votes' do
        let!(:vote) { create(:vote, shop: shop) }
        let(:last_reviewed_schema) { { '@type' => 'lastReviewed', 'dateTime' => vote.created_at } }

        subject { helper.send(:structured_data_hash)['@graph'] }

        it { is_expected.to include(last_reviewed_schema) }
      end

      context 'no votes' do
        subject { helper.send(:structured_data_hash)['@graph'].map {|h| h["@type"]} }

        it { is_expected.to include('WebSite') }
        it { is_expected.not_to include('lastReviewed') }
      end
    end

    context 'when page has categories' do
      let(:test_category_name) { 'Test name' }
      let(:test_category_url) { 'test_url' }
      before { helper.add_collection_page_element(test_category_name, test_category_url) }

      subject { helper.send(:structured_data_hash)['@graph'].map { |h| h["@type"] } }

      it { is_expected.to include('CollectionPage') }
      it { is_expected.not_to include('WebPage') }

      context 'when CollectionPage valid' do
        let(:valid_collection_page_schema) {
          {
              '@type' => 'CollectionPage',
              'mainEntity' => {
                  '@type' => 'ItemList',
                  'itemListElement' => [{
                      '@type' => 'ItemPage',
                      'name'  => test_category_name,
                      'url'   => test_category_url
                  }]
              }
          }
        }

        subject { helper.send(:collection_page_base) }

        it { is_expected.to eq(valid_collection_page_schema) }
      end
    end

    context 'when page has no categories' do
      subject { helper.send(:structured_data_hash)['@graph'].map { |h| h["@type"] } }

      it { is_expected.to include('WebPage') }
      it { is_expected.not_to include('CollectionPage') }
    end
  end
end
