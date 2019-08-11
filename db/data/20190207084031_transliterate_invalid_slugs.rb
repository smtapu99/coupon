class TransliterateInvalidSlugs < ActiveRecord::Migration[5.2]
  include ApplicationHelper

  def up
    RedirectRule.transaction do
      begin
        Site.active.each do |site|
          Site.current = site

          [Shop, Category, StaticPage, Campaign].each do |sluggable_class|
            sluggable_class.where(status: 'active', site_id: site.id).where('slug <> CONVERT(slug USING ASCII) OR slug LIKE "%.%"').each do |record|
              update_invalid_slug(record)

              if record.is_a?(Category) && record.sub_categories.present?
                record.sub_categories.each do |category|
                  update_invalid_slug(category)
                end
              end

              if record.is_a?(Shop) && record.campaigns.present?
                record.campaigns.each do |campaign|
                  update_invalid_slug(campaign)
                end
              end

              if record.is_a?(Campaign) && record.sub_campaigns.present?
                record.sub_campaigns.each do |campaign|
                  update_invalid_slug(campaign)
                end
              end
            end
          end
        rescue Exception => e
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def update_invalid_slug(record)
    old_slug = record.slug
    new_slug = old_slug.transliterate.parameterize

    old_source = generate_url_for(record)
    record.assign_attributes slug: new_slug
    new_destination = generate_url_for(record)

    if record.update_column :slug, new_slug
      rule = RedirectRule.create(
          site_id: Site.current.id,
          source: old_source,
          destination: new_destination,
          active: 1,
          request_environment_rules:
              [RequestEnvironmentRule.new(environment_key_name: 'SERVER_NAME',environment_value: Site.current.hostname)]
      )
    else
      raise ActiveRecord::Rollback
    end
  end

  def generate_url_for(record)
    if record.is_a?(Campaign)
      dynamic_campaign_url_for(record, only_path: true)
    else
      opts = {}
      opts[:only_path] = true
      opts[:host] = Site.current.hostname
      opts[:slug] = record.slug
      opts[:parent_slug] = record.parent_slug if record.respond_to?(:parent_slug)

      dynamic_url_for(record.class.to_s.singularize.downcase, 'show', opts)
    end
  end
end
