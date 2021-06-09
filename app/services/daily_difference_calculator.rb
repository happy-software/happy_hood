class DailyDifferenceCalculator
  attr_reader :hoods

  def initialize(hoods)
    @hoods  = hoods
  end

  def differences
    hoods.map do |hood|
      difference_details(hood)
    end
  end

  private

  HoodSummary = Struct.new(
    :name,
    :last_valuation,
    :last_valuation_date,
    :todays_valuation,
    :valuation_difference,
    :house_count,
    :average_house_diff,
    keyword_init: true,
  )

  def difference_details(hood)
    last_valuation       = hood.valuation_before(Date.today)
    todays_valuation     = hood.valuation_on(Date.today)
    difference           = todays_valuation - last_valuation[:valuation]
    house_count          = hood.houses.count
    average_house_diff   = difference / house_count if house_count > 1

    HoodSummary.new(
      name: hood.name,
      last_valuation: last_valuation[:valuation],
      last_valuation_date: last_valuation[:date],
      todays_valuation: todays_valuation,
      valuation_difference: difference,
      house_count: house_count,
      average_house_diff: average_house_diff,
    )
  end
end
