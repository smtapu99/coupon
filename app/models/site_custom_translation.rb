class SiteCustomTranslation < ApplicationRecord
  include ActsAsSiteable

  belongs_to :translation
end
