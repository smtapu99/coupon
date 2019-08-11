class BookmarksController < FrontendController

  def index
    not_found if Setting::get('publisher_site.allow_coupon_bookmarks', default: 0).to_i.zero?

    add_default_breadcrumbs
    add_body_tracking_data

    content_for :robots, 'noindex,follow'
    content_for :title, 'Bookmarks'

    render layout: default_layout
  end

  def saved_coupons
    ids = cookies[:saved_coupons]

    if ids.present?
      @coupons = @site.coupons.where(id: ids.split(','))
      surrogate_key_header 'coupons', @coupons.map(&:resource_key)
    end

    respond_to do |format|
      format.js
    end
  end

  # bookmarks a coupon
  def save
    # set_cache_buster
    if @site.coupons.where(id: params[:id]).any?
      add_to_bookmark_cookie(params[:id])
      render plain: 'success'
    else
      render plain: 'error'
    end
  end

  # deletes a bookmarked coupon
  def unsave
    remove_from_bookmark_cookie(params[:id])
    render plain: 'success'
  end

  def active_bookmarks_count
    ids = cookies[:saved_coupons]

    if ids.present?
      render plain: reset_bookmark_cookie(@site.coupons.where(id: ids.split(',')).pluck(:id))
    else
      render plain: 0
    end
  end

  private
    def reset_bookmark_cookie(ids = nil)
      cookies.delete :saved_coupons

      if ids != nil
        ids.each do |id|
          add_to_bookmark_cookie(id)
        end
      end

      return ids.count
    end

    def add_to_bookmark_cookie(id)
      string = cookies[:saved_coupons] || ''
      cookies.permanent[:saved_coupons] = ((string.split(',')) << id).uniq.join(',')
    end

    def remove_from_bookmark_cookie id
      return false unless cookies[:saved_coupons]

      string = cookies[:saved_coupons].split(',')
      string.delete(id)
      cookies.permanent[:saved_coupons] = string.join(',')

      if cookies[:saved_coupons].size == 0
        cookies.delete :saved_coupons
      end
    end
end
