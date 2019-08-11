class ExternalUrlsController < FrontendController
  before_action :get_external_url, only: [:out]

  def out
    url = sanitize_url_or_path(@external_url.url)

    if url.blank?
      not_found
    else
      no_index

      if Setting::get('publisher_site.reduced_js_features', default: 0).to_i == 1
        render layout: false
      else
        redirect_to(url, status: :temporary_redirect)
      end
    end
  end

  private

  def get_external_url
    # check if a string was passed that isnt an integer
    if params[:id].to_i == 0
      render plain: 'Invalid Request', :status => :service_unavailable and return
    end

    @external_url = ExternalUrl.find_by(id: params[:id]) || not_found
  end
end
