class BannerLocation < ApplicationRecord
  belongs_to :banner
  belongs_to :bannerable, polymorphic: true
end
