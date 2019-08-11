class Resources::V1::Shops < Grape::API

  helpers do
    def render_shop(shop)
      {
        id: shop.id,
        name: shop.title
      }
    end
  end

  resources :shops do

    before { init_site }

    desc "Return all shops. Limit is 100 shops at a time"
    params do
      optional :limit, type: Integer, desc: "limit (max: 100)", default: 100
      optional :offset, type: Integer, desc: "offset", default: 0
    end

    get '/' do
      limit = sanitized_limit(100)
      offset = sanitized_offset

      unpaginated = @site.shops.order_by_priority
      records = unpaginated.limit(limit).offset(offset).map { |shop| render_shop(shop) }
      formatted_output('shops', records, unpaginated.count, limit, offset)
    end

    desc "Return a single shop"
    get ':id' do
      shop = @site.shops.find_by(id: params[:id])
      return render_shop(shop) if shop.present?
      {}
    end
  end
end
