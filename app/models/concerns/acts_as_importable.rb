module ActsAsImportable
  extend ActiveSupport::Concern

  included do
    require 'rubygems'
    require 'roo'
    include Rails.application.routes.url_helpers
    include ApplicationHelper

    serialize :error_messages
    mount_uploader :file, Admin::JobFileUploader
    validates_presence_of :file

    validate :site_id_column_present?, if: :global_import?

    private

    def site_id_column_present?
      spreadsheet = open_spreadsheet
      header = spreadsheet.row(1)

      unless header.include?('Site ID')
        errors.add(:file, ': This is a multi-site import. Pls add a column "Site ID" to your import file')
        return
      end

      # and if yes, take Site ID column and check if there is any site_id that is NOT in the allowed_site_ids
      not_allowed_site_ids = detect_forbidden_site_ids(spreadsheet)
      return unless not_allowed_site_ids.count.positive?

      errors.add(:site, 'not allowed; You can not upload to this sites: ' + not_allowed_site_ids.to_sentence)
    end

    def sanitize_https(value)
      return value unless value.to_s.start_with?('//')
      'https:' + value
    end

    def upload_url
      if file.cached?
        file.full_cache_path
      else
        file_url
      end
    end

    def detect_forbidden_site_ids(spreadsheet)
      header = spreadsheet.row(1)
      allowed_user_site_ids = User.current.sites.pluck(:id).map(&:to_s)
      spreadsheet.column(header.find_index('Site ID') + 1)[1..spreadsheet.last_row].uniq.reject { |id| allowed_user_site_ids.include?(id.to_s) }
    end

    def update_priority_scores(uniq_sites)
      Shop::calculate_priorities(uniq_sites)
      Coupon::calculate_priorities(uniq_sites)
    end

    def purge_related_sites(sites)
      sites.each do |site|
        purge_urls = @urls.uniq.select { |url| url.include?(site.hostname) }
        CacheService.new(site).purge(purge_urls)
      end
    rescue StandardError
      false
    end

    def global_import?
      !self.is_a?(TagImport)
    end

    def open_spreadsheet
      case File.extname(upload_url)
      when '.csv' then Roo::CSV.new(upload_url, csv_options: { col_sep: ';' })
      when '.xls' then Roo::Spreadsheet.open(upload_url, extension: :xls)
      when '.xlsx' then Roo::Spreadsheet.open(upload_url, extension: :xlsx)
      else raise "Unknown file type: #{upload_url}"
      end
    end
  end
end
