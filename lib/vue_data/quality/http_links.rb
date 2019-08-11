module VueData
  class Quality::HttpLinks < VueData::Quality
    private

    def records
      site_current = ::Site.find(@site_id)
      ::HtmlDocument.
          where(htmlable: [site_current.shops, site_current.campaigns, site_current.static_pages]).
          where('content LIKE ?', "%http://#{site_current.hostname}%").
          with_filter(filter_params)
    end

    def records_paginated
      records.
          page(page).
          per(per_page).
          order(order.gsub('object', 'htmlable') => direction)
    end

    def data(record)
      {
          object_id: record.htmlable_id,
          object_type: record.htmlable_type.underscore,
          message: 'Container http onpage links in content'
      }
    end

    def filter_params
      params.slice(:object_id, :object_type).transform_keys { |key| key.gsub('object', 'htmlable').prepend('with_')}
    end
  end
end
