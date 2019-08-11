class ReportForm < MailForm::Base
  attribute :name,       validate: true
  attribute :email,      validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :shopname
  attribute :discount
  attribute :link_to_offer
  attribute :remark

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: Site.current.hostname + ' - Report',
      to: Setting.get('mail_forms.contact_emails', default: "info@#{Site.current.hostname}"),
      from: 'no-reply@savings-united.com',
      reply_to: %("#{name}" <#{email}>)
    }
  end
end
