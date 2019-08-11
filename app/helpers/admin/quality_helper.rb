module Admin
  module QualityHelper
    def can_manage_quality_section?
      case
      when params[:controller] == 'admin/expired_exclusives'
        can? :update, Coupon
      when params[:controller] == 'admin/quality' && params[:action] == 'active_coupons'
        can? :update, Shop
      else
        true
      end
    end
  end
end
