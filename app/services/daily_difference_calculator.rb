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

  HoodSummary = Struct.new(:name, :yesterdays_valuation, :todays_valuation, :valuation_difference, :house_count, :valuation_date)

  def difference_details(hood)
    yesterdays_valuation = hood.valuation_on(Date.yesterday)
    todays_valuation     = hood.valuation_on(Date.today)
    difference           = todays_valuation - yesterdays_valuation

    HoodSummary.new(
      hood.name,
      yesterdays_valuation,
      todays_valuation,
      difference,
      hood.houses.count,
      Date.today
    )
  end
end
