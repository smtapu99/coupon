describe Translation, type: :model do
  let!(:site) { create :site }
  let!(:translation) { create :translation }

  it "has a valid factory" do
    expect(translation).to be_valid
  end

  context '#distinct_keys' do
    let!(:another_site) { create :site }
    let!(:translation) { create :translation, key: 'my-key', value: 'my-value' }
    let!(:sc1) { create :site_custom_translation, translation: translation, site: site, value: 'sc1' }
    let!(:sc2) { create :site_custom_translation, translation: translation, site: another_site, value: 'sc2' }

    subject { Translation.distinct_keys }

    it 'when Site.current.blank? it raises Invalid Site error' do
      expect { subject }.to raise_error('Invalid Site')
    end

    context 'when Site.current.present?' do
      before { Site.current = another_site }
      it { is_expected.to match_array([['my-key', 'sc2']]) }
    end

    context 'when untranslated keys from same locale exists' do
      let!(:untranslated) { create :translation, key: 'untranslated', value: nil }
      before { Site.current = site }
      it { is_expected.to match_array([['my-key', 'sc1'], ['untranslated', nil]]) }

      context 'and site 58 (independent) exists' do
        let!(:independent) { create :site, id: 58 }
        let!(:indy_sc) { create :site_custom_translation, translation: translation, site: independent, value: 'indy-value' }
        it { is_expected.to match_array([['my-key', 'sc1']]) }
      end
    end
  end

  context '.customize' do
    it 'without site custom returns translation.value' do
      expect(translation.reload.value).to eq('value')
    end

    context 'with site custom translation' do
      before { create :site_custom_translation, site: site, translation: translation, value: 'new value' }

      it 'returns value of translation if Site.current.blank?' do
        Site.current = nil
        expect(translation.reload.value).to eq('value')
      end

      it 'returns value of site_custom_translation' do
        Site.current = site
        expect(translation.reload.value).to eq('new value')
      end
    end
  end
end
