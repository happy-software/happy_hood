class Hood < ApplicationRecord
  has_many :houses
  has_many :home_owners_associations

  def valuation_before(date)
    house_count = houses.count

    # keep track of dates, and how many houses had a price at that point in time
    # default number of houses to 0
    dates_with_valuations = houses.flat_map {|house| house.price_history.keys }

    # array to hash
    date_to_house_counts = dates_with_valuations.each_with_object(Hash.new(0)) do |date, date_to_occurances|
      date_to_occurances[date] += 1
    end

    # find the dates where all houses had pricing
    date_where_all_houses_have_pricing = date_to_house_counts.select do |_, date_house_count|
      date_house_count == house_count
    end

    # find the max date where all houses had pricing
    latest_date_with_pricing = date_where_all_houses_have_pricing.keys.map do |pricing_date|
      price_date = Date.strptime(pricing_date)

      if price_date < date
        price_date
      end
    end.compact.max

    {
      date: latest_date_with_pricing,
      valuation: valuation_on(latest_date_with_pricing),
    }
  end

  def valuation_on(date)
    return 0 if date.nil?

    houses.map { |house| house.valuation_on(date) }.sum
  end
end
