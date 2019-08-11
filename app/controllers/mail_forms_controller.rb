class MailFormsController < FrontendController
  ALLOWED_SUBMITS = 3

  before_action :set_metas, only: [:new, :create]
  before_action :set_setting, only: [:new]
  before_action :set_type, only: [:new, :create]
  before_action :set_defaults, only: [:new, :create]

  def new
    not_found if @setting.present? && @setting.send("#{@type}_form_enabled") == '0'
    @message = model_class.new

    add_default_breadcrumbs
    content_for :title, @site.site.hostname.titleize + ' | ' + @title
  end

  def create
    @message = model_class.new(mail_form_params[params_key])
    @message.request = request

    if !form_submit_allowed?(sha_cache_key)
      flash.now[:error] = @too_many_requests_message
    elsif @message.deliver && ApplicationMailer.contact_confirmation(@message.email, Site.current).deliver
      flash.now[:notice] = @success_message
    else
      flash.now[:error] = @error_message
    end

    content_for :title, @site.site.hostname.titleize + ' | ' + @title
    render action: :new
  end

  private

  def form_submit_allowed?(cache_key)
    count = Rails.cache.read(cache_key, raw: true) || 0
    return false if count.to_i >= ALLOWED_SUBMITS.to_i

    # extend expiration to x time after last attempt
    Rails.cache.write(cache_key, count.to_i + 1, expires_in: 1.hour, raw: true)
    true
  end

  def sha_cache_key
    'mail_form_submits_' + (session[:subIdTracking] || 'null')
  end

  def set_metas
    content_for :canonical, original_url_with_custom_protocol
    content_for :robots, 'noindex,nofollow'
  end

  def set_defaults
    @too_many_requests_message = I18n.t :YOU_HAVE_REACHED_THE_QUOTA_OF_ALLOWED_SUBMISSIONS, default: 'You have reached the quota of allowed submission requests. Please try again later.'

    case @type
    when 'contact'
      @title = I18n.t :HEADLINE_CONTACT_PAGE, default: 'HEADLINE_CONTACT_PAGE'
      @success_message = I18n.t :POP_UP_TEXT_REMARK_SENT, default: 'POP_UP_TEXT_REMARK_SENT'
      @error_message = I18n.t :CONTACT_PAGE_ERROR_MESSAGE, default: 'CONTACT_PAGE_ERROR_MESSAGE'
    when 'report'
      @title = I18n.t :HEADLINE_REPORT_OFFER_PAGE, default: 'HEADLINE_REPORT_OFFER_PAGE'
      @success_message = I18n.t :POP_UP_TEXT_OFFER_SENT, default: 'POP_UP_TEXT_OFFER_SENT'
      @error_message = I18n.t :CONTACT_PAGE_ERROR_MESSAGE, default: 'CONTACT_PAGE_ERROR_MESSAGE'
    when 'partner'
      @title = I18n.t :HEADLINE_PARTNER_PAGE, default: 'HEADLINE_PARTNER_PAGE'
      @success_message = I18n.t :POP_UP_TEXT_PARTNERFORM_SENT, default: 'POP_UP_TEXT_PARTNERFORM_SENT'
      @error_message = I18n.t :CONTACT_PAGE_ERROR_MESSAGE, default: 'CONTACT_PAGE_ERROR_MESSAGE'
    end
  end

  def set_setting
    @setting = Setting.current_mail_forms
  end

  def set_type
    @type = params[:type] || 'contact'
  end

  def model_class
    model_class = (@type + '_form').camelize.constantize
  end

  def params_key
    @params_key ||= params.keys.select { |key| %w(contact_form report_form partner_form).include? key }.first.to_s
  end

  def mail_form_params
    params.select do |key|
      [:contact_form, :report_form, :partner_form].include? key.to_sym
    end
  end
end
