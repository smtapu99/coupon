module ActsAsSluggable
  extend ActiveSupport::Concern

  included do

    attr_accessor :slug_mutable

    before_validation :calculate_slug, if: -> { slug.blank? }
    before_validation :sanitize_slug

    validates :slug, immutable: true, unless: :slug_mutable
    validates :slug, format: { without: /\s/,  message: 'is invalid, no spaces allowed' }
    validates_format_of :slug, with: /\A[\w\d\/-]+\z/, message: 'is invalid, only slash and alphanumeric character is allowed'
    validates_presence_of :slug

    validates_uniqueness_of :slug, if: -> { !self.respond_to?('site_id') }
    validates_uniqueness_of :slug, scope: :site_id, if: -> { self.respond_to?("site_id") && self.class.name != "Campaign" }
    validates_uniqueness_of :slug, scope: [:site_id, :shop_id], if: -> { self.respond_to?("site_id") && self.class.name == "Campaign" }

    def sanitize_slug
      self.slug = self.slug.strip.downcase if self.slug.is_a?String
    end

    def calculate_slug
      if new_record?
        self.slug = sluggify_me
      else
        # in case the entity has a empty slug on update
        # create the slug again from the title or name
        # update_column skips the validation which prevents
        # updating the slug
        self.update_column(:slug, sluggify_me)
      end
    end

    # creates a slug from name or title, dependent of what the model responds to
    #
    # @return [String] Slug
    def sluggify_me
      if self.respond_to?('title') && self.title.present?
        self.title.to_slug
      elsif self.respond_to?('name') && self.name.present?
        self.name.to_slug
      end
    end
  end
end
