class CampaignImport < ApplicationRecord
  include ActsAsImportable

  belongs_to :user
  validates_presence_of :user_id

  def run
    error_messages = []
    uniq_sites = []
    @urls = []
    @root_campaigns = []

    Campaign.transaction do
      load_imported_campaigns.each_with_index do |campaign, index|
        if campaign.valid?
          uniq_sites << campaign.site
          uniq_sites.uniq!
          campaign.save!
        else
          campaign.errors.full_messages.each do |message|
            error_messages << "Row #{index+2}: #{message}"
          end
        end
      end
    end

    if error_messages.present?
      update_attributes(error_messages: error_messages, status: 'error')
      return false
    else
      update_attribute(:status, 'done')

      # reload routes timestamp for each uniq site
      if @root_campaigns.present?
        uniq_sites.each do |site|
          RoutesChangedTimestamp.update_timestamp(site)
        end
        DynamicRoutes.reload
        # add reloaded root campaign routes to @urls
        @root_campaigns.each { |campaign| @urls << dynamic_campaign_url_for(campaign) }
      end

      purge_related_sites(uniq_sites)
      return true
    end
  end

  def self.grid_filter(params)
    query = self
    query = query.where(user: User.current.allowed_active_users_of(self, true)) if User.current.present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where(user: params[:user]) if params[:user].present?
    query = query.where('file like ?', "%#{params[:file]}%") if params[:file].present?
    query = query.where(status: params[:status]) if params[:status].present?
    query = query.where('created_at >= ?', params['created_at_from']) if params['created_at_from'].present?
    query = query.where('created_at <= ?', params['created_at_to']) if params['created_at_to'].present?

    query
  end

  def self.grid_filter_dropdowns
    h = {}
    h[:user] = User.current.allowed_active_users_of(self, true).map do |user|
      { user.id => user.full_name }
    end
    h[:user].insert(0, { '' => 'all' })
    h
  end

  private

  def load_imported_campaigns
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      site_id = row['Site ID'].to_i

      if row['Campaign ID'].present?
        campaign = Campaign.find_by(id: row['Campaign ID'].to_i, site_id: site_id)
      else
        campaign = Campaign.find_or_initialize_by(
          site_id: site_id,
          name: row['Name'],
          slug: row['Slug'].to_s.downcase
        )
      end
      Site.current = campaign.site
      Time.zone = campaign.site.timezone

      campaign_all_rows = row.to_hash.slice(*Campaign::allowed_import_params)
      campaign_html_all_rows = row.to_hash.slice(*HtmlDocument::allowed_import_params(user))
      campaign_setting_publisher_site_all_rows = row.to_hash.slice(*Setting::publisher_site_allowed_import_params)

      campaign_new_hash = {}
      html_document_new_hash = {}
      publisher_new_hash = {}

      campaign_all_rows.each_pair do |key, value|
        case key
        when 'Site ID'
          key = 'site_id'
          value = campaign.site_id # avoid overwriting the site_id
        when 'Parent ID'
          key   = 'parent_id'
          value = value.present? ? value.to_i : campaign.parent_id
        when 'Coupon Filter Headline'
          key   = 'coupon_filter_text'
          value = value.present? ? value : campaign.coupon_filter_text
        when 'Priority Coupon IDs'
          key   = 'priority_coupon_ids'
          value = value.present? ? value.to_s.split(',').reject{ |i| i.empty? || i == ' ' }.map{ |i| i.gsub(' ', '') }.join(',') : nil
        when 'End Date'
          key   = 'end_date'
          value = value.present? ? DateTime.parse("#{value} 23:59:59").to_s(:db) : campaign.end_date
        when 'H1 First Line'
          key   = 'h1_first_line'
          value = value.present? ? value : campaign.h1_first_line
        when 'H1 Second Line'
          key   = 'h1_second_line'
          value = value.present? ? value : campaign.h1_second_line
        when 'Name'
          key = 'name'
          value = value.present? ? value : campaign.name
        when 'Nav Title'
          key   = 'nav_title'
          value = value.present? ? value : campaign.nav_title
        when 'SEO Text Headline'
          campaign_all_rows.delete('SEO Text Headline')
        when 'SEO Text'
          campaign_html_all_rows['Content'] = value unless campaign_html_all_rows['content'].present?
          campaign_all_rows.delete('SEO Text')
        when 'Shop'
          key   = 'shop_id'
          shop  = Shop.find_by(slug: value.to_s.downcase, site_id: site_id) if value.present?
          value = shop.present? ? shop.id : campaign.shop_id
        when 'Slug'
          key   = 'slug'
          value = value.present? ? value : campaign.slug
        when 'Start Date'
          key   = 'start_date'
          value = value.present? ? DateTime.parse("#{value} 00:00:00").to_s(:db) : campaign.start_date
        when 'Status'
          key   = 'status'
          value = value.present? ? value : campaign.status
        when 'Is Root Campaign'
          key = 'is_root_campaign'

          if value.present?
            value = value == 'yes' ? 1 : 0
          else
            value = shop.is_root_campaign
          end
        when 'SEM Page Logo URL'
          key = 'sem_logo_url'
          value = value.present? ? value : campaign.sem_logo_url
        when 'SEM Page Background URL'
          key = 'sem_background_url'
          value = value.present? ? value : campaign.sem_background_url
        when 'Template'
          key = 'template'
          value = value.present? ? value : campaign.template
        end

        campaign_new_hash.merge!({ key => value }) if key != 'SEO Text' && key != 'SEO Text Headline'
      end

      campaign_html_all_rows.each_pair do |key, value|
        case key
        when 'Meta Robots'
          key = 'meta_robots'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.meta_robots.present?
              value = campaign.html_document.meta_robots
            end
          end
        when 'Meta Keywords'
          key = 'meta_keywords'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.meta_keywords.present?
              value = campaign.html_document.meta_keywords
            end
          end
        when 'Meta Description'
          key = 'meta_description'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.meta_description.present?
              value = campaign.html_document.meta_description
            end
          end
        when 'Meta Title'
          key = 'meta_title'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.meta_title.present?
              value = campaign.html_document.meta_title
            end
          end
        when 'H2'
          key = 'h2'
          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.h2.present?
              value = campaign.html_document.h2
            end
          end
        when 'Welcome Text'
          key = 'welcome_text'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.welcome_text.present?
              value = campaign.html_document.welcome_text
            end
          end
        when 'Content'
          key = 'content'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.content.present?
              value = campaign.html_document.content
            end
          end
        when 'Header Image'
          key = 'remote_header_image_url'
          value = value.present? ? sanitize_https(value) : campaign.try(:html_document).try(:remote_header_image_url)

          next if campaign.try(:html_document).try(:remote_header_image_url) == value
        when 'Mobile Header Image'
          key = 'remote_mobile_header_image_url'
          value = value.present? ? sanitize_https(value) : campaign.try(:html_document).try(:remote_mobile_header_image_url)

          next if campaign.try(:html_document).try(:remote_mobile_header_image_url) == value
        when 'Header Font Color'
          key = 'header_font_color'

          if value.present?
            value
          else
            if campaign.html_document.present? && campaign.html_document.header_font_color.present?
              value = campaign.html_document.header_font_color
            end
          end
        end

        html_document_new_hash.merge!({ key => value })
      end

      campaign_setting_publisher_site_all_rows.each_pair do |key, value|
        case key
        when 'Show Footer'
          key = 'show_footer'

          if value.present?
            value = value == 'yes' ? 1 : 0
          else
            if campaign.setting.present? && campaign.setting.publisher_site.present? && campaign.setting.publisher_site.show_footer.present?
              value = campaign.setting.publisher_site.show_footer
            end
          end
        when 'Custom Head Scripts'
          key = 'custom_head_scripts'

          if value.present?
            value
          else
            if campaign.setting.present? && campaign.setting.publisher_site.present? && campaign.setting.publisher_site.custom_head_scripts.present?
              value = campaign.setting.publisher_site.custom_head_scripts
            end
          end
        end

        publisher_new_hash.merge!({ key => value })
      end

      campaign.attributes = campaign_new_hash
      campaign.html_document_attributes = html_document_new_hash
      campaign.setting_attributes = { 'publisher_site' => publisher_new_hash }
      campaign.is_imported = 1

      add_url_for_purging(campaign)

      @root_campaigns << campaign if campaign.is_root_campaign?

      campaign
    end
  end

  def add_url_for_purging(campaign)
    (@urls ||= []) << dynamic_url_for('campaigns', 'show', slug: campaign.slug, parent_slug: campaign.parent_slug, shop_slug: campaign.shop_slug, only_path: false)
  end
end
