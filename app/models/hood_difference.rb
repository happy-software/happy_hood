  class HoodDifference
    def initialize(hood, start_date:, end_date:)
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
      @earliest_valuation ||= get_earliest_valuation[:valuation]
    end

    def earliest_valuation_date
      @earliest_valuation_date ||= get_earliest_valuation[:date]
    end

    def latest_valuation
      @latest_valuation ||= get_latest_valuation[:valuation]
    end

    def latest_valuation_date
      @latest_valuation_date ||= get_latest_valuation[:date]
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

    def average_house_price
      latest_valuation / house_count
    end

    private

    def get_earliest_valuation
      @get_earliest_valuation ||= @hood.valuation_on_or_before(@start_date)
    end

    def get_latest_valuation
      @get_latest_valuation ||= @hood.valuation_on_or_before(@end_date)
    end
  end
