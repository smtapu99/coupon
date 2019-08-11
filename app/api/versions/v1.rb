class Versions::V1 < Grape::API
  version 'v1', using: :path
  default_format :json
  format :json
  formatter :json, Grape::Formatter::Rabl

  mount Resources::V1::Cron

  before do
    authenticate!
  end

  helpers do
    def init_site
      @site = SiteFacade.new(@current_site)

      Site.current = @site.site
      Time.zone = @site.site.timezone
      I18n.locale = @site.site.country.locale
      I18n.global_scope = :frontend
    end

    def sanitized_limit(max=50)
      return 1 if params[:limit].to_i < 1
      return 50 if params[:limit].to_i > 50
      params[:limit].to_i
    end

    def sanitized_offset
      return 0 if params[:offset].to_i < 0
      params[:offset].to_i
    end

    def sanitized_csv(csv)
      csv.gsub(' ', '').split(',') if csv.present?
    end

    def max_offset(total_count, limit)
      total_count - (total_count % limit > 0 ? total_count % limit : limit)
    end

    def formatted_output(class_name, records, total_count, limit, offset)
      {
        "#{class_name}": records,
        limit: limit,
        offset: offset,
        total: total_count,
        max_offset: max_offset(total_count, limit)
      }
    end
  end

  mount Resources::V1::Snippets
  mount Resources::V1::Shops
  mount Resources::V1::Coupons
end
