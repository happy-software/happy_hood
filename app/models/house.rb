class House < ApplicationRecord
  belongs_to :hood
  has_many :home_owners_associations, through: :hood
end
