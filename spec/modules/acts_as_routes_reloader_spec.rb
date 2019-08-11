describe 'ActsAsRoutesReloader' do
  let!(:site) { create :site, hostname: 'test.host' }

  context 'on save' do
    let!(:setting) { create :setting, site: site, routes: { application_root_dir: '/path' } }

    it 'reloads routes' do
      expect(send("root_#{site.id}_url")).to eq('http://test.host/path')
    end
    it 'reloads routes if avoid_reload_routes = false' do
      setting.avoid_reload_routes = false
      setting.update(routes: { application_root_dir: '/other-path' })
      expect(send("root_#{site.id}_url")).to eq('http://test.host/other-path')
    end

    it 'doesnt reloads routes if avoid_reload_routes = true' do
      setting.avoid_reload_routes = true
      setting.update(routes: { application_root_dir: '/other-path' })
      expect(send("root_#{site.id}_url")).to eq('http://test.host/path')
    end
  end
end
