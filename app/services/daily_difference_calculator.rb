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

  HoodSummary = Struct.new(:name, :yesterdays_valuation, :todays_valuation, :valuation_difference, :house_count, :valuation_date, :average_house_diff, keyword_init: true)

  def difference_details(hood)
    yesterdays_valuation = hood.valuation_on(Date.yesterday)
    todays_valuation     = hood.valuation_on(Date.today)
    difference           = todays_valuation - yesterdays_valuation
    house_count         = hood.houses.count
    average_house_diff   = difference / house_count if house_count > 1

    HoodSummary.new(
      name: hood.name,
      yesterdays_valuation: yesterdays_valuation,
      todays_valuation: todays_valuation,
      valuation_difference: difference,
      house_count: house_count,
      average_house_diff: average_house_diff,
      valuation_date: Date.today,
    )
  end
end
