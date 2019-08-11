describe 'localization' do
  let(:rfc_5646_regex) { /^[a-z]{2,3}(?:-[A-Z]{2,3}(?:-[a-zA-Z]{4})?)?$/ }
  let(:global_scope) { :frontend }
  let(:locale) { 'en-US' }

  before do
    I18n.global_scope = global_scope
    I18n.locale = locale
  end

  context 'when files are in place for all available_locales' do
    subject do
      lambda do
        I18n.available_locales.each do |locale|
          I18n.locale = locale
          I18n.l Time.now
        end
      end
    end

    it { is_expected.to_not raise_error }
  end

  context 'when available_locales matches rfc_5646 format' do
    subject { I18n.available_locales }

    it { is_expected.to all(match(rfc_5646_regex)) }
  end

  context 'when I18n.global_scope = :frontend' do
    let(:date) { Time.now.to_date }
    let(:date_default_en_format) { date.strftime('%m-%d-%Y') }

    context 'when localization has the correct format (en-US)' do
      it { expect(I18n.locale.to_s).to eq(locale.to_s) }
      it { expect(I18n.l date).to eq(date_default_en_format) }
    end

    context 'when translation exist' do
      let(:translation) { create :translation, locale: locale }

      subject { I18n.t translation.key }

      it { is_expected.to eq(translation.value) }
    end
  end
end
