class HousePrice < ApplicationRecord
  belongs_to :house

  scope :on, -> (date) { where(valuation_date: date) }
end
