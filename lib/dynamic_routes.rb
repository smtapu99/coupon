class DynamicRoutes

  # dynamically loads the routes from settings into the routes.rb file
  # and adds a host constraint to just match with the current sites host
  # http://codeconnoisseur.org/ramblings/creating-dynamic-routes-at-runtime-in-rails-4
  def self.load
    if database_exists? && Site.table_exists?
      Frontend::Application.routes.draw do
        Site.active.each do |site|

          # Root Campaigns
          if ActiveRecord::Base.connection.column_exists?(:campaigns, :is_root_campaign)
            # also create routes for inactive campaigns
            root_campaigns = site.root_campaigns

            self.constraints(host: site.hostname) do
              root_campaigns.each do |campaign|
                if campaign.parent_id.present?
                  match "/#{campaign.parent_slug}/#{campaign.slug}", format: false, to: 'campaigns#show', parent_slug: campaign.parent_slug, slug: campaign.slug, via: [:get], as: "root_campaign_#{campaign.id}"
                else
                  match "/#{campaign.slug}", format: false, to: 'campaigns#show', slug: campaign.slug, via: [:get], as: "root_campaign_#{campaign.id}"
                end
              end
            end if root_campaigns.present?
          end

          app_root_dir = site.setting.get('routes.application_root_dir', default: nil) if site.setting.present?
          if app_root_dir.present?
            scope app_root_dir do
              DynamicRoutes::load_default_routes(site, self)
              DynamicRoutes::load_dynamic_routes_for(site, self)
            end
          else
            DynamicRoutes::load_default_routes(site, self)
            DynamicRoutes::load_dynamic_routes_for(site, self)
          end
        end
      end
    end
  end

  # allows to reload the routing
  # e.g. when changes in route settings where made
  #
  def self.reload
    Rails.application.reload_routes!
  end

  private

  def self.database_exists?
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    false
  else
    true
  end

  def self.load_static_redirects
  end

  def self.load_dynamic_routes_for(site, mapper)
    site.routes.each do |route|
      # write the route with the host constraint
      mapper.constraints(host: site.hostname) do
        case route[0]
        when :contact_form
          mapper.match route[1].to_s, format: false, to: 'mail_forms#new', type: 'contact', via: [:get], as: "contact_#{site.id}"
        when :report_form
          mapper.match route[1].to_s, format: false, to: 'mail_forms#new', type: 'report', via: [:get], as: "report_#{site.id}"
        when :partner_form
          mapper.match route[1].to_s, format: false, to: 'mail_forms#new', type: 'partner', via: [:get], as: "partner_#{site.id}"
        when :page_show
          mapper.match route[1].to_s, format: false, to: 'pages#show', via: [:get], as: "page_show_#{site.id}"
        when :shop_index
          mapper.match route[1].to_s, format: false, to: 'shops#index', via: [:get], as: "shops_index_#{site.id}"
        when :category
          mapper.match route[1].to_s, format: false, to: 'categories#index', via: [:get], as: "categories_index_#{site.id}"
        when :subcategory_show
          mapper.match route[1].to_s, format: false, to: 'categories#show', via: [:get], as: "subcategory_show_#{site.id}"
        when :category_show
          mapper.match route[1].to_s, format: false, to: 'categories#show', via: [:get], as: "category_show_#{site.id}"
        when :go_to_coupon
          mapper.match route[1].to_s, format: false, to: 'coupons#clickout', via: [:get], as: "coupon_clickout_#{site.id}", constraints: {id: /[\*0-9]+/} # the * is used in robots.txt
        when :popular_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'popular', via: [:get], as: "coupons_popular_#{site.id}"
        when :top_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'top', via: [:get], as: "coupons_top_#{site.id}"
        when :new_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'new', via: [:get], as: "coupons_new_#{site.id}"
        when :expiring_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'expiring', via: [:get], as: "coupons_expiring_#{site.id}"
        when :free_delivery_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'free_delivery', via: [:get], as: "coupons_free_delivery_#{site.id}"
        when :free_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'free', via: [:get], as: "coupons_free_#{site.id}"
        when :exclusive_coupons
          mapper.match route[1].to_s, format: false, to: 'coupons#index', type: 'exclusive', via: [:get], as: "coupons_exclusive_#{site.id}"
        when :campaign_page
          mapper.match route[1].to_s, format: false, to: 'campaigns#show', via: [:get], as: "campaign_show_#{site.id}"
        when :search_page
          mapper.match route[1].to_s, format: false, to: 'searches#index', via: [:get], as: "searches_index_#{site.id}"
        when :shop_show # put show show at the end of the routes as mostly the shops are accessed just with /:slug ( but this rule would cath all requests )
          if route[1] == '/:slug.html'
            mapper.match route[1].to_s, to: 'shops#show', via: [:get], as: "shop_show_#{site.id}", constraints: {format: 'html' }
          elsif route[1] == '/:slug'
            mapper.match route[1].to_s, to: 'shops#show', via: [:get], as: "shop_show_#{site.id}", constraints: {format: '' }
          else
            mapper.match route[1].to_s, format: false, to: 'shops#show', via: [:get], as: "shop_show_#{site.id}", constraints: lambda { |r| r.path.include? route[1].split(':slug').first }
          end
        when :campaign_sub_page
          # this matches /amazon/campaigns correctly to campaign show
          mapper.match route[1].to_s, format: false, to: 'campaigns#show', via: [:get], as: "campaign_sub_page_#{site.id}", constraints: lambda { |r|
            return false if r.path.include? '/pcadmin/'
            if route[1].include?('.html')
              r.path.include?('.html')
            else
              true
            end
          }
        when :shop_campaign_page
          # this matches /amazon/campaigns correctly to campaign show
          mapper.match route[1].to_s, format: false, to: 'campaigns#show', via: [:get], as: "shop_campaign_#{site.id}", constraints: lambda { |r|
            return false if r.path.include? '/pcadmin/'
            if route[1].include?('.html')
              r.path.include?('.html')
            else
              true
            end
          }
        end
      end
    end
  end

  def self.load_default_routes(site, mapper)
    mapper.constraints(host: site.hostname) do
      mapper.root 'home#index', as: "root_#{site.id}"

      # errors
      mapper.get "/404", to: "errors#not_found", as: "error_not_found_#{site.id}"
      mapper.get "/422", to: "errors#unacceptable", as: "error_unacceptable_#{site.id}"
      mapper.get "/500", to: "errors#internal_error", as: "error_internal_error_#{site.id}"

      # robots
      mapper.get 'robots', to: 'robots#index', as: "robots_index_#{site.id}"

      # external urls
      mapper.get '/out/:id', to: 'external_urls#out', as: "external_url_out_#{site.id}"
      mapper.get '/api-clickout/:id', to: 'coupons#api_clickout', as: "api_clickout_#{site.id}"

      # frontend
      mapper.match 'searches/autocomplete' => 'searches#autocomplete', via: [:post, :get], as: "searches_autocomplete_#{site.id}"
      mapper.match 'searches/shop_autocomplete' => 'searches#shop_autocomplete', via: [:post, :get], as: "searches_shop_autocomplete_#{site.id}"
      mapper.match 'newsletter_subscribers/subscribe' => 'newsletter_subscribers#subscribe', via: [:post, :get], as: "subscribe_#{site.id}"
      mapper.match 'tracking/set' => 'trackings#set', via: [:post], as: "tracking_set_#{site.id}"
      mapper.match 'snippets/top' => 'snippets#top', via: [:get], as: "snippet_top_#{site.id}"
      mapper.match 'snippets/:id' => 'snippets#show', via: [:get], as: "snippet_show_#{site.id}"
      mapper.match 'api/publisher/:id/script.js' => 'snippets#render_snippet', via: [:get], as: "snippet_render_top_snippet_#{site.id}"
      mapper.match 'shops/vote' => 'shops#vote', via: [:post, :get], as: "shop_vote_#{site.id}"
      mapper.match 'shops/render_votes' => 'shops#render_votes', via: [:get], as: "shop_render_votes_#{site.id}"
      mapper.match 'coupons/vote' => 'coupons#vote', via: [:get], as: "coupon_vote_#{site.id}"
      mapper.match 'voucher' => 'coupons#voucher', via: [:get], as: "coupon_voucher_#{site.id}"
      mapper.match 'bookmarks/save' => 'bookmarks#save', via: [:post], as: "bookmark_save_#{site.id}"
      mapper.match 'bookmarks/unsave' => 'bookmarks#unsave', via: [:post], as: "bookmark_unsave_#{site.id}"
      mapper.match 'bookmarks/active_bookmarks_count' => 'bookmarks#active_bookmarks_count', via: [:post], as: "bookmarks_active_bookmarks_count_#{site.id}"
      mapper.match 'bookmarks/saved_coupons' => 'bookmarks#saved_coupons', via: [:post], as: "bookmarks_saved_coupons_#{site.id}"
      mapper.match 'bookmarks' => 'bookmarks#index', via: [:get], as: "bookmarks_index_#{site.id}"

      # Modals - AJAX Requests
      mapper.get '/modals/help', to: 'modals#help', as: "modals_help_#{site.id}"
      mapper.get '/modals/coupon_share_modal/:id', to: 'modals#coupon_share', as: "modals_coupon_share_#{site.id}"
      mapper.get '/modals/coupon_clickout', to: 'modals#coupon_clickout', as: "modals_coupon_clickout_#{site.id}"
      mapper.get '/modals/newsletter_subscribe', to: 'modals#newsletter_subscribe', as: "modals_newsletter_subscribe_#{site.id}"

      # sitemap
      mapper.get '/sitemap.:format', to: 'sitemaps#index', as: "sitemaps_#{site.id}"
      mapper.get '/sitemap/:type.:format', to: 'sitemaps#index', as: "sitemaps_type_#{site.id}"

      # contact forms
      mapper.post '/contact', to: 'mail_forms#create', type: 'contact', as: "send_contact_form_#{site.id}"
      mapper.post '/partner', to: 'mail_forms#create', type: 'partner', as: "send_partner_form_#{site.id}"
      mapper.post '/report',  to: 'mail_forms#create', type: 'report',  as: "send_report_form_#{site.id}"

      # html partials
      mapper.get '/static/header', to: 'pages#header', as: "static_header_#{site.id}"
      mapper.get '/static/footer', to: 'pages#footer', as: "static_footer_#{site.id}"

      # deals
      mapper.get '/deals/:slug', to: 'campaigns#sem', as: "campaign_sem_#{site.id}"
    end
  end
end
