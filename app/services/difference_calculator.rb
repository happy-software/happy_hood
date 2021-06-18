class DifferenceCalculator
  def initialize(hoods, start_date:, end_date:)
    @hoods = hoods
    @start_date = start_date
    @end_date = end_date
  end

  def differences
    @hoods.map do |hood|
      HoodDifference.build_for(hood, start_date: @start_date, end_date: @end_date)
    end
  end
end
