module ActsAsSiteable
  extend ActiveSupport::Concern

  included do

    # Associations
    belongs_to :site

    # Callbacks
    before_validation :add_current_site

    # Validations
    validates :site_id, immutable: true # Site_id must not be changed, due to the urls which would throw 404 errors
    validates_presence_of :site_id
    validates_numericality_of :site_id, greater_than: 0, message: 'Please select a valid Site'

    # Save site_id if its not coming from the form
    # and if its not an update, this prevents from updating the site_id
    # by just switching the current site.
    #
    # Allows everybody except the publisher
    def add_current_site
      if new_record? && Site.current.present? && self.site_id.to_i.zero?
        self.site_id = Site.current.id
      end
    end

    # Get records per site
    def self.by_current_site
      where site_id: Site.current.id if Site.current
    end

    # Get records per site
    #
    # @return [Array<Category>] categories_by_site
    def self.by_site site_id=nil
      if site_id.nil?
        self.by_current_site
      else
        where(site_id: site_id)
      end
    end
  end
end
