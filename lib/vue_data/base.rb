module VueData
  class Base
    def self.render_json(site_id, params={})
      new(site_id, params).render_json
    end

    def initialize(site_id, params={})
      @site_id = site_id
      @params = params
    end

    def render_json
      {
        page: page,
        order: order,
        per_page: per_page,
        order_direction: direction,
        count: records_count,
        records: records_data,
        filters: filters
      }.to_json
    end

    private

    def page
      @params[:page] || 1
    end

    def per_page
      @params[:per_page] || 20
    end

    def params
      @merged_params ||= merge_params
    end

    def merge_params
      return @params[:f] ||= {} unless @site_id.present?
      (@params[:f] ||= {}).merge(site_id: @site_id)
    end

    def order
      @params[:order] || 'id'
    end

    def direction
      %w[asc desc].include?(@params[:order_direction]) ? @params[:order_direction] : 'desc'
    end

    def records_paginated
      records.page(page).per(per_page).order(order => direction)
    end

    def records_count
      records.size
    end

    def records_data
      records_paginated.map { |record| data(record) }
    end

    def filters
      {}
    end

    # overwrite this default implementation if needed
    # @return JSON
    def data(record)
      record.serializable_hash
    end

    # overwrite this default implementation if needed
    # @return JSON
    def records
      raise NotImplementedError, '"records" is not implemented'
    end
  end
end
