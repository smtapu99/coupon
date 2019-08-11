class NewsletterSubscribersController < FrontendController
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  def subscribe
    force_xhr; return if performed?

    @subscriber = MailchimpSubscriber.new(email_params, Site.current)
    @subscriber.subscribe(params[:merge_vars])

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private

  def email_params
    params.require(:email)
  end

  def render_bad_request
    head(:bad_request)
  end
end
