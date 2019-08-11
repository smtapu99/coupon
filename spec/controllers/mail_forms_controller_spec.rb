describe MailFormsController do
  let!(:site) { create :site, hostname: 'www.example.com' }

  context '.form_submit_allowed?' do
    it 'returns true if submitted requests <= 3' do
      Rails.cache.delete('mail_forms_submit_1')

      controller = MailFormsController.new
      expect(controller.instance_eval { form_submit_allowed?('mail_forms_submit_1') }).to eq(true)
      expect(controller.instance_eval { form_submit_allowed?('mail_forms_submit_1') }).to eq(true)
      expect(controller.instance_eval { form_submit_allowed?('mail_forms_submit_1') }).to eq(true)
      expect(controller.instance_eval { form_submit_allowed?('mail_forms_submit_1') }).to eq(false)
    end
  end
end
