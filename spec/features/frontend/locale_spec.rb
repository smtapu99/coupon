describe "setting locale" do

  include_context 'a basic frontend'

  before do
    I18n.locale = I18n.default_locale
    Translation.store('es-ES',
       :H1_MAINPAGE => "My personal H1"
    )
  end

  after do
    I18n.locale = I18n.default_locale
  end

  xit "should be translating" do
    visit '/'
    expect(page).to have_content 'My personal H1'
  end
end
