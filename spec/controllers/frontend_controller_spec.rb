describe FrontendController do
  let!(:site) { create :site, hostname: 'test.host', time_zone: 'Berlin' }

  context 'init_site' do
    subject { assigns(:site) }
    before { get :not_found }
    it { is_expected.to be_a(SiteFacade) }
  end

  context 'init_setting' do
    let!(:setting) { create :setting, site: site }
    before { get :not_found }
    subject { RequestStore.store[:setting_current] }
    it {  is_expected.to_not be_nil }
  end

  context 'init_translations' do
    let!(:translation) { create :site_custom_translation, site: site }
    before { get :not_found }
    subject { I18n.translations_timestamp }
    it {  is_expected.to eq translation.updated_at.to_i }
  end

  context 'set_home_breadcrumb' do
    before { get :not_found }
    subject { assigns(:breadcrumbs) }
    it {  is_expected.to_not be_nil }
  end

  context 'set_current_time_zone' do
    before { get :not_found }
    subject { Time.zone.name }
    it {  is_expected.to eq('Berlin') }
  end

  context 'set_i18n_globals' do
    before { get :not_found }
    subject { I18n.global_scope }
    it {  is_expected.to eq(:frontend) }
  end

  context 'set_layout' do
    context 'when custom layout empty' do
      before { get :not_found }
      subject { assigns(:layout) }
      it { is_expected.to eq('frontend') }
    end

    context 'when custom layout set' do
      let!(:option) { create :option, name: 'custom_layout', value: '<html>', site_id: site.id }
      before { get :not_found }
      subject { assigns(:layout) }
      it { is_expected.to eq('custom') }
    end
  end

  context 'set_session_vars' do
    before do
      request.cookies['subIdTracking'] = '12345'
      get :not_found
    end
    subject { request.session['subIdTracking'] }
    it { is_expected.to eq('12345') }
  end

  context 'set_global_surrogate_key' do
    let!(:setting) { create :setting, caching: { use_surrogate_keys: '1' }, site_id: site.id }
    before { get :not_found }
    subject { response.headers['Surrogate-Key'] }
    it { is_expected.to include(site.surrogate_key) }
  end

  context 'set_theme' do
    let!(:setting) { create :setting, style: { theme: 'custom-theme' }, site_id: site.id }
    before { get :not_found }
    subject { Theme.current }
    it { is_expected.to eq('custom-theme') }
  end


  context 'init_campaign' do
  end

  xcontext 'set_social_image' do
  end

  xcontext 'set_shops_for_search_autocomplete' do
  end

  xcontext 'set_menu_categories' do
  end

  xcontext 'set_bucket_asset_path' do
  end

  context 'theme_view_path' do
  end

end
