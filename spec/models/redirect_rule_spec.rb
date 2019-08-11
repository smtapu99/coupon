require 'rails_helper'

describe 'RedirectRule' do

  context '::destination_for' do
    let!(:site) { create(:site, hostname: 'www.example.com', setting: Setting.new(name: 'setting')) }
    let!(:redirect_rule) { create(:redirect_rule, :destination => '/to.html', :source => '/', site_id: site.id) }

    it 'correctly redirects the visitor for an exact match rule' do
      expect(RedirectRule.destination_for('/', {'SERVER_NAME' => 'www.example.com'})).to eq('/to.html')
    end

    it 'doesnt redirect when hostname doesnt match' do
      expect(RedirectRule.destination_for('/', {'SERVER_NAME' => 'www.other-example.com'})).to eq(nil)
    end

    it 'doesnt redirect when RedirectRule is inactive' do
      redirect_rule.update_attribute(:active, false)
      expect(RedirectRule.destination_for('/', {'SERVER_NAME' => 'www.example.com'})).to eq(nil)
    end
  end
end
