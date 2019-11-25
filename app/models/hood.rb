class Hood < ApplicationRecord
  has_many :houses
  has_many :home_owners_associations

  scope :valuation_on, -> (date) { houses.map { |h| h.house_prices.on(date).last&.price }.compact.sum }

end
