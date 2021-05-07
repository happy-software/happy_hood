namespace :one_offs do
  desc "Migrates Zillow house prices from legacy house_prices table to the houses.price_history column"
  task backfill_house_prices: :environment do
    # Iterate through each `House` |h|
    #   - Iterate through each h.house_prices |hp|
    #     - h.price_history[hp.normalized_date] ||= hp.price
    House.find_each do |house|
      price_history = house.price_history || {}
      house.house_prices.find_each do |price|
        normalized_valuation_date = price.valuation_date.strftime("%Y-%m-%d")
        price_history[normalized_valuation_date] ||= price.price
      end
      house.price_history = price_history
      house.save!
    end
  end
end
