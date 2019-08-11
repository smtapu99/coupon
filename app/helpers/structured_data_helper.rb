module StructuredDataHelper

  def site_navigation_element(opts = {})
    (@site_navigation_elements ||= []) << {
      '@type' => 'SiteNavigationElement',
      '@id' => '#navigation',
      'name' => opts[:name],
      'url' => opts[:url]
    }
  end

  def breadcrumbs_element(opts={})
    (@breadcrumb_elements ||= []) << {
      '@type' => 'ListItem',
      'position' => opts[:position],
      'item' => {
        '@id' => opts[:item],
        'name' => opts[:name]
      }
    }
  end

  def add_collection_page_element(name, url)
    (@collection_page_elements ||= []) << {
        '@type' => 'ItemPage',
        'name'  => name,
        'url'   => url
    }
  end

  def render_structured_data
    content_tag(:script, JSON.pretty_generate(structured_data_hash), { type: 'application/ld+json' }, false).html_safe
  end

  private

  def structured_data_hash
    base['@graph'] << website_base
    base['@graph'] << (@collection_page_elements.present? ? collection_page_base : webpage_base)
    base['@graph'] << last_reviewed_base if last_reviewed_base
    base['@graph'] << breadcrumbs_base if @breadcrumb_elements.present?
    base['@graph'] += @site_navigation_elements if @site_navigation_elements.present?
    base
  end

  def base
    @base ||= {
      '@context' => 'http://schema.org',
      '@graph' => []
    }
  end

  def breadcrumbs_base
    {
      '@type' => 'BreadcrumbList',
      'itemListElement' => @breadcrumb_elements
    }
  end

  def website_base
    {
      '@type' => 'WebSite',
      'url' => root_url,
      'potentialAction' => {
        '@type' => 'SearchAction',
        'target' => dynamic_url_for('searches', 'index', only_path: false) + '?query={query}',
        'query-input' => 'required name=query'
      }
    }
  end

  def webpage_base
    webpage_element = {
      '@type' => 'WebPage',
      'url' => original_url_with_custom_protocol
    }

    webpage_element['description'] = content_for(:description) if content_for?(:description)
    webpage_element['name'] = content_for(:title) if content_for?(:title)

    if show_aggregate_rating?
      webpage_element['AggregateRating'] = {
        '@type' => 'AggregateRating',
        'name' => @shop.title,
        'ratingValue' => @shop.formatted_rating,
        'reviewCount' => @shop.total_votes,
        'worstRating' => 0,
        'bestRating' => 5
      }
    end

    if content_for?(:social_image)
      webpage_element['primaryImageOfPage'] = {
        '@type' => 'ImageObject',
        'contentUrl' => content_for(:social_image)
      }
    end

    webpage_element
  end

  def collection_page_base
    {
        '@type' => 'CollectionPage',
        'mainEntity' => {
            '@type' => 'ItemList',
            'itemListElement' => @collection_page_elements
        }
    }
  end

  def last_reviewed_base
    @last_reviewed_base ||= last_reviewed_schema if show_aggregate_rating?
  end

  def last_reviewed_schema
    if datetime = @shop.votes&.last&.created_at
      {
        '@type' => 'lastReviewed',
        'dateTime' => datetime
      }
    end
  end

  def show_aggregate_rating?
    is_shop? && @shop.present? && @shop.rating.to_f >= Setting::get('publisher_site.hide_star_rating', default: 2.5).to_f
  end
end
