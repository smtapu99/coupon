module ActsAsAlgoliaSearchable
  extend ActiveSupport::Concern

  included do
    include AlgoliaSearch

    algoliasearch index_name: ActsAsAlgoliaSearchable.config_index_name(self.name), disable_indexing: Rails.env.test?, if: :is_active_and_visible?  do
      attributes :title, :site_id, :status, :tier_group
      attribute :priority_score do
        priority_score.to_f
      end
      attributesForFaceting ['site_id']

      customRanking ['asc(tier_group)', 'desc(priority_score)']
    end

    def self.algolia_search(query, options)
      options.merge!(facetFilters: ["site_id:#{Site.current.id}"])

      begin
        self.search(query, options)
      rescue Algolia::AlgoliaProtocolError => e
        return []
      end
    end

  end

  def self.config_index_name(index_name)
    "#{index_name}_#{ENV['ALGOLIA_INDEX_SUFFIX']}"
  end
end
