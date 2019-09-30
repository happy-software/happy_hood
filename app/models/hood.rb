class Hood < ApplicationRecord
  has_many :houses
  has_many :home_owners_associations

end
