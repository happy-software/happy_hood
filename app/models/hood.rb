class Hood < ApplicationRecord
  has_many :houses
  has_many :home_owners_associations


  def valuation_on(date)
    houses.map do |h|
      normalized_date = date.strftime("%Y-%m-%d")
      h.price_history.dig(normalized_date).to_f
    end.compact.sum
  end
end
