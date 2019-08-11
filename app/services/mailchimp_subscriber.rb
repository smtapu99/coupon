# sub = MailchimpSubscriber.new('mpeuerboeck@gmail.com', Site.first)
# sub.subscribe
class MailchimpSubscriber
  attr_reader :site, :email, :member, :error

  MERGE_VAR_DEFAULTS = {
    'GENERAL' => 'all'
  }.freeze

  def initialize(email, site)
    @site = site
    @email = email
    @options = site.setting.try(:newsletter)
    @list_id = @options.try(:mailchimp_list_id)
    @api_key = @options.try(:mailchimp_api_key)

    # retrieve member here to check for duplicate signups
    retrieve_member
  end

  def subscribe(merge_vars = nil)
    @merge_vars = merge_vars
    @member = gibbon_list_member.upsert(member_body)
  rescue Gibbon::MailChimpError => e
    @error = e
    false
  end

  def status
    @member.body['status'] if @member.present?
  end

  def new?
    !@member.present? || status != 'subscribed'
  end

  def update?
    @member_present
  end

  def error?
    @error.present?
  end

  def reload_member
    retrieve_member
  end

  private

  # returns nil in case the member doesnt exist yet
  def retrieve_member
    @member = gibbon_list_member.retrieve
    @member_present = @member.present?
    @member
  rescue Gibbon::MailChimpError => e
    @member_present = false
    nil
  end

  # all
  def merge_defaults
    (@merge_vars ||= {}).merge(MERGE_VAR_DEFAULTS)
  end

  # the member body. Status only updates unless the user
  # is already subscribed
  def member_body
    body = {
      body: {
        email_address: email,
        merge_fields: merge_defaults
      }
    }
    body[:body][:status] = 'pending' unless member_subscribed?
    body
  end

  def gibbon_list_member
    gibbon.lists(@list_id).members(Digest::MD5.hexdigest(@email.downcase))
  end

  def member_subscribed?
    @member.present? && @member.body['status'] == 'subscribed'
  end

  def gibbon
    @gibbon ||= init_gibbon
  end

  def init_gibbon
    Gibbon::Request.api_key = @api_key
    Gibbon::Request.timeout = 15
    Gibbon::Request.throws_exceptions = true
    Gibbon::Request.new
  end
end
