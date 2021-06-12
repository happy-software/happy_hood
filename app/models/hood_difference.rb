  class HoodDifference
    def initialize(hood, start_date: nil, end_date: Date.today)
      @hood = hood
      @start_date = start_date
      @end_date = end_date
    end

    def self.build_for(hood, start_date:, end_date:)
      new(hood, start_date: start_date, end_date: end_date)
    end

    def empty?
      valuation_difference.zero?
    end

    def hood_name
      @hood.name
    end

    def earliest_valuation
      @earliest_valuation ||= begin
                                calculate_and_memoize_earliest_valuation
                                @earliest_valuation
                              end
    end

    def earliest_valuation_date
      @earliest_valuation_date ||= begin
                                     calculate_and_memoize_earliest_valuation
                                     @earliest_valuation_date
                                   end
    end

    def latest_valuation
      @latest_valuation ||= begin
                              calculate_and_memoize_latest_valuation
                              @latest_valuation
                            end
    end

    def latest_valuation_date
      @latest_valuation_date ||= begin
                                   calculate_and_memoize_latest_valuation

                                   @latest_valuation_date
                                 end
    end

    def valuation_difference
      @valuation_difference ||= latest_valuation - earliest_valuation
    end

    def house_count
      @house_count ||= @hood.houses.count
    end

    def average_house_difference
      valuation_difference / house_count if house_count > 1
    end

    private

    def calculate_and_memoize_earliest_valuation
      date = if @start_date.nil? || @start_date.to_date == 1.day.ago.to_date
               1.day.ago
             else
               @start_date + 1.day
             end

      valuation = @hood.valuation_before(date)

      @earliest_valuation_date = valuation[:date]
      @earliest_valuation = valuation[:valuation]
    end

    def calculate_and_memoize_latest_valuation
      valuation = @hood.valuation_before(@end_date + 1.day)

      @latest_valuation_date = valuation[:date]
      @latest_valuation = valuation[:valuation]
    end
  end
