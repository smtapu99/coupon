describe PrepareSiteService do

  let!(:country) { create :country, name: 'Spain', locale: 'es-ES'}
  let!(:from_site) { create :site, name: 'from', country: country }
  let!(:to_site) { create :site, name: 'to', country: country }

  let!(:translation) { create :translation, locale: country.locale }
  let!(:category) { create :category, :with_html_document_index, site: from_site }


  describe '::call' do

    before do
      Site.current = to_site
      from_site.site_custom_translations << SiteCustomTranslation.new(translation_id: translation.id, value: 'test')
      from_site.setting = build :setting, site: from_site, routes: { application_root_dir: '/test' }
      PrepareSiteService.call(to_site, from_site, true)
    end

    it 'copies categories' do
      expect(to_site.categories.count).to eq 1
    end

    it 'copies html_documents of categories' do
      expect(to_site.categories.first.try(:html_document).try(:meta_robots)).to eq category.html_document.meta_robots
    end

    it 'copies translations' do
      expect(to_site.site_custom_translations.count).to eq 1
    end

    it 'copies routes' do
      expect(to_site.setting.value[:routes]).to eq(OpenStruct.new({ application_root_dir: '/test' }))
    end

  end

end

