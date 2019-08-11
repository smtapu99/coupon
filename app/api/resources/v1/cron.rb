class Resources::V1::Cron < Grape::API
  resources :cron do
    get :active_coupons_count do
      error!('Forbidden.', 403) unless request.headers['X-Appengine-Cron']
      Resque.enqueue(CronWorker, 'active_coupons_count:all')
    end

    get :generate_alerts do
      Resque.enqueue(CronWorker, 'alerts:generate')
    end
  end
end
