class ErrorsController < FrontendController
  def not_found
    @coupons = @site.coupons.by_type('top').order(clicks: :desc).limit(10)
    render 'not_found.html', status: 404, layout: default_layout
  end

  def unacceptable
    render :status => 422, layout: false, format: 'html'
  end

  def internal_error
    render :status => 500, layout: false, format: 'html'
  end
end
