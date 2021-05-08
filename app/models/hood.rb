class Hood < ApplicationRecord
  has_many :houses
  has_many :home_owners_associations

  scope :valuation_on, -> (date) { houses.map { |h| h.price_history.dig(date.strftime("%Y-%m-%d")).to_f }.compact.sum }

end
