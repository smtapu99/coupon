class ContactForm < MailForm::Base
  attribute :name,       validate: true
  attribute :email,      validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :phone
  attribute :reason
  attribute :message

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: Site.current.hostname + ' - Contact',
      to: Setting.get('mail_forms.contact_emails', default: "info@#{Site.current.hostname}"),
      from: 'no-reply@savings-united.com',
      reply_to: %("#{name}" <#{email}>)
    }
  end

  def self.reasons
    [
      I18n.t(:REPORT_BUG_DROPDOWN, default: 'REPORT_BUG_DROPDOWN'),
      I18n.t(:REPORT_KOMMENT_DROPDOWN, default: 'REPORT_KOMMENT_DROPDOWN'),
      I18n.t(:GIVE_HINT_DROPDOWN, default: 'GIVE_HINT_DROPDOWN'),
      I18n.t(:OTHER_DROP_DOWN, default: 'OTHER_DROP_DOWN'),
    ]
  end
end
