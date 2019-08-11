describe I18n do
  let!(:site) { create :site }
  let!(:locale) { :en }

  before do
    I18n.locale = locale
    Site.current = site
  end

  context '::t' do
    let!(:key) { 'TEST_KEY' }

    let!(:translation) { create :translation, key: key, value: 'value', locale: locale }
    let!(:custom_translation) { create :site_custom_translation, translation: translation, site: site, value: 'custom value' }

    subject { I18n::t(key, default: 'default value') }

    context 'when global_scope isnt frontend' do
      before { I18n.global_scope = nil }

      it { is_expected.to eq('default value') }
    end

    context 'when global_scope is frontend' do
      before { I18n.global_scope = :frontend }

      context 'when no translation exists' do
        it { is_expected.to eq('custom value') }
      end


      context 'when Site.current is other site' do
        let!(:other_site) { create :site }
        let!(:other_custom_translation) { create :site_custom_translation, translation: translation, site: other_site, value: 'other value' }

        it 'fetches the translation from the other site' do
          Site.current = site
          expect(I18n::t(key, default: 'default value')).to eq('custom value')
          Site.current = other_site
          expect(I18n::t(key, default: 'default value')).to eq('other value')
        end
      end

      context 'when translation doesnt exist' do
        it 'creates translation' do
          subject
          expect(Translation.count).to eq(1)
        end
      end

      context 'when I18n.shop_scope.present?' do
        let!(:scoped_key) { "123_#{key}" }
        before { I18n.shop_scope = 123 }

        context 'when scoped translation exits' do
          let!(:other_translation) { create :translation, key: scoped_key, value: 'value', locale: locale }
          let!(:custom_translation) { create :site_custom_translation, translation: other_translation, site: site, value: 'scoped value' }
          it { is_expected.to eq('scoped value') }
        end

        context 'when scoped translation was updated' do
          let!(:other_translation) { create :translation, key: scoped_key, value: 'v2alue', locale: locale }
          let!(:custom_translation) { create :site_custom_translation, translation: other_translation, site: site, value: 'scoped value' }

          before {
            params = {site_custom_translation_attributes: {id: custom_translation.id, value: 'new value'}}
            other_translation.update(params)
          }

          it { is_expected.to eq('new value') }
        end

        context 'when scoped translation was cached before updated' do
          let!(:other_translation) { create :translation, key: scoped_key, value: 'v2alue', locale: locale }
          let!(:custom_translation) { create :site_custom_translation, translation: other_translation, site: site, value: 'scoped value' }

          before {
            I18n.t(scoped_key)
            params = {site_custom_translation_attributes: {id: custom_translation.id, value: 'new value'}}
            other_translation.update(params)
          }

          it 'should clean cache and return new value' do
            expect(Rails.cache.fetch(I18n.backend.send(:lookup_key, locale, scoped_key))).to be_nil
            is_expected.to eq('new value')
          end
        end

        context 'when scoped translation doesnt exist' do
          before { I18n.shop_scope = 456 }
          it { is_expected.to eq('custom value') }
        end

        context 'when Site.current is other site' do
          let!(:other_site) { create :site }
          let!(:translation) { create :translation, key: scoped_key, value: 'value', locale: locale }
          let!(:other_custom_translation) { create :site_custom_translation, translation: translation, site: other_site, value: 'other scoped value' }

          it 'fetches the translation from the other site' do
            Site.current = site
            expect(I18n::t(key, default: 'default value')).to eq('custom value')
            Site.current = other_site
            expect(I18n::t(key, default: 'default value')).to eq('other scoped value')
          end
        end

        context 'when scoped translation doesnt exit' do
          it { is_expected.to eq('custom value') }

          it 'doesnt create translation with scoped_key' do
            subject
            expect(Translation.where(key: scoped_key).count).to eq(0)
          end
        end
      end
    end
  end
end
