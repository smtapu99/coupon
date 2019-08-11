require 'resque/server'

Frontend::Application.routes.draw do
  mount Api => '/api'

  root 'home#index'

  get '/admin',   to: redirect('pcadmin/home')
  get '/pcadmin', to: redirect('pcadmin/home')
  match '/admin/:name', to: redirect("pcadmin/%{name}"), via: [:get, :post]

  namespace :pcadmin, module: :admin, as: :admin do

    root 'home#index'

    match '/widgets/update_widget_area' => 'widgets#update_widget_area', via: [:get]
    match '/categories/change_status' => 'categories#change_status', via: [:get]
    match '/coupons/change_status' => 'coupons#change_status', via: [:get]
    match '/shops/change_status' => 'shops#change_status', via: [:get]
    match '/shops/order_coupons' => 'shops#order_coupons', via: [:get]
    match '/shops/update_coupon_order' => 'shops#update_coupon_order', via: [:get]
    match '/shops/import_template' => 'shops#import_template', via: [:get]
    match '/coupons/import_template' => 'coupons#import_template', via: [:get]
    match '/campaigns/import_template' => 'campaigns#import_template', via: [:get]
    match '/tags/import_template' => 'tags#import_template', via: [:get]
    match '/shops/update_shop_list_priority' => 'shops#update_shop_list_priority', via: [:post]
    match '/templates/save' => 'templates#save', via: [:post]
    match '/templates/get_layout' => 'templates#get_layout', via: [:get]
    match '/templates/restore_default' => 'templates#restore_default', via: [:get]
    match '/templates/delete_layout' => 'templates#delete_layout', via: [:delete]
    match '/caches' => 'caches#purge_url', via: [:post]
    match '/awin' => 'awin_migration#awin', via: [:get]
    match '/reload_routes' => 'settings#reload_routes', via: [:get]
    match '/migrate_awin' => 'awin_migration#migrate_awin', via: [:post]
    match '/shops/render_shops_select' => 'shops#render_shops_select', via: [:get]

    devise_for :users, class_name: 'User', controllers: {
      passwords:     'admin/passwords',
      registrations: 'admin/registrations',
      sessions:      'admin/sessions'
    }

    scope :users, as: :users do
      devise_scope :admin_user do
        post 'pre_sign_in', to: 'sessions#pre_sign_in'
      end
      resource :two_factors, only: [:create, :destroy], controller: 'users/two_factors'
    end

    authenticate do
      mount Resque::Server, :at => "/tasks"
    end

    resources :affiliate_networks, only: [:index, :new, :edit, :create, :update]

    resources :alerts, only: [:index, :destroy, :edit] do
      member do
        post 'mark_solved', to: 'alerts#mark_solved'
      end
    end

    resources :authors, only: [:index, :new, :edit, :create, :update]

    resources :banners

    resources :caches, only: [:index]

    resources :campaigns, only: [:index, :new, :edit, :create, :update] do
      collection do
        get 'export_modal'
        get 'export'
      end
    end

    resources :campaign_imports

    resources :categories, only: [:index, :new, :edit, :create, :update] do
      collection do
        get 'order'
        post 'order', to: 'categories#update_order'
      end
    end

    resources :countries, only: [:index, :new, :edit, :create, :update]

    resources :coupons, only: [:index, :new, :edit, :create, :update] do
      collection do
        get 'export_modal'
        get 'export'
      end
      member do
        get 'coupon_codes', to: 'coupons#coupon_codes'
      end
    end

    resources :coupon_codes, only: [:index, :new, :edit, :create, :update, :import] do
      collection do
        get 'approve_imported'
        get 'remove_imported'
        get 'export_modal'
        get 'export'
      end
    end

    resources :coupon_imports

    resources :coupon_code_imports, only: [:new, :create]

    resources :csv_exports, only: [:index, :edit, :destroy] do
      member do
        get 'rerun'
      end
    end

    resources :globals do
      collection do
        get 'export_modal'
        get 'export'
        get 'shop_mappings'
        post 'update_shop_mapping'
      end
    end

    resources :home, only: [:index]

    resources :media, only: [:index, :new, :edit, :create, :update]

    resources :options

    scope :quality do
      get 'active_coupons', to: 'quality#active_coupons'
      get 'http_links', to: 'quality#http_links'
      get 'invalid_urls', to: 'quality#invalid_urls'

      resources :expired_exclusives, only: [:index, :edit] do
        collection do
          get 'edit', to: 'expired_exclusives#edit', as: 'bulk_edit'
          post 'update', to: 'expired_exclusives#update', as: 'update'
        end
      end
    end

    resources :redirect_rules

    resources :settings, only: [:index, :update]

    patch :image_settings, to: 'settings#update_image_settings', as: :image_settings

    resources :shop_imports

    resources :shops, only: [:index, :new, :edit, :create, :update] do
      collection do
        get 'export_modal'
        get 'export'
        get 'synch_keywords'
      end
    end

    resources :sites, only: [:index, :new, :edit, :create, :update]

    resources :snippets, only: [:index, :new, :edit, :create, :update]

    resources :static_pages, only: [:index, :new, :edit, :create, :update]

    resources :tags do
      collection do
        get 'export_modal'
        get 'export'
      end
    end

    resources :tag_imports

    resources :templates, only: [:index]

    resources :tracking_clicks

    resources :tracking_users

    resources :translations do
      collection do
        get 'export_keys'
      end
    end

    resources :widgets

    resources :users, only: [:index, :new, :edit, :create, :update] do
      get '/current_site_id/:site_id', to: 'users#set_current_site_id'  , as: 'site_id'
      get '/unset_current_site_id'   , to: 'users#unset_current_site_id', as: 'unset_site_id'
    end
  end

  get '/index.php',       to: redirect('/')
  get '/index.php/*path', to: redirect{|params, request| "/#{params[:path]}#{ '.'+params[:format] if params[:format].present? }"}

  # FRONTEND ROUTES ARE LOADED DYNAMICALLY

  # DynamicRoutes.load_static_redirects

  DynamicRoutes.load

  # This is a fallback if no route can be matched and if not even the frontend controller is triggered to forward to a 404 page
  match "*path", to: "frontend#not_found", via: :all
  post "/", to: "frontend#not_found"
end
