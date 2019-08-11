class Relation < ApplicationRecord

  belongs_to :relation_from, polymorphic: true, validate: false
  belongs_to :relation_to, polymorphic: true, validate: false

end
