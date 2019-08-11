class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@savings-united.com"
  default reply_to: "info@savings-united.com"

  layout false

  def inform_developer(subject, data)
    @subject = subject
    @data = data

    mail(to: 'mike.peuerboeck@savings-united.com', subject: subject)
  end

  def contact_confirmation(email, site)
    reply_to = site.setting.mail_forms.contact_emails.split(',').first rescue "info@#{site.only_domain}"

    mail(
      to: email,
      reply_to: reply_to,
      subject: t(:THANKS_FOR_CONTACTING_US, default: 'Thanks for contacting us')
    )
  end
end
