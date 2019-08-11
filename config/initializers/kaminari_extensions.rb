module Kaminari
  module Helpers
    class Tag
      def dynamic_page_url_for(page)
        if !@params[:controller].present? || !@params[:action].present?
          raise 'Kaminari Error; Please specify params[:controller] && params[:action] to use the dynamic_url_for method in pagination'
        end
        # alias_action is used as we use a "filter" method in some controllers; so we know what the real action e.g. is "show" instead of "filter". Check the routes eg shop#show!
        action = @params.delete(:alias_action) || @params.delete(:action)

        # theme is not needed in the url of the pagination CA-1101
        theme  = Theme.current
        @params.delete(:filter)

        if(@params[:shop_slug].present?)
          @template.send("shop_campaign_#{Site.current.id}_path", @params.merge(@param_name => (page <= 1 ? nil : page)))
        else
          @template.dynamic_url_for(@params.delete(:controller), action , @params.merge(@param_name => (page <= 1 ? nil : page)))
        end
      end

      def page_url_for(page)
        @template.url_for @params.merge(@param_name => (page <= 1 ? nil : page), :only_path => true)
      end
    end

    # Tag that contains a link
    module Link
      # the link's href
      def url
        if I18n.global_scope == :frontend && !@params[:controller].start_with?('admin/')
          dynamic_page_url_for page
        else
          page_url_for page
        end
      end
    end
  end
end
