class DifferenceRenderer
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Helpers::DateHelper

  SHORT_DATE_FORMAT = "%b %d, %Y".freeze

  def self.summarize_differences(hood_differences)
    hood_differences
      .reject(&:empty?)
      .map { |hood_difference| new(hood_difference).render }
      .join("\n")
  end

  def initialize(hood_difference)
    @difference = hood_difference
  end

  def render
    average_house_difference = if @difference.average_house_difference
                                 avg_diff_string = if @difference.average_house_difference.positive?
                                                     "+#{currency_format(@difference.average_house_difference)}"
                                                   else
                                                     currency_format(@difference.average_house_difference)
                                                   end

                                 "(#{avg_diff_string} avg/house)"
                               end

    difference = if @difference.valuation_difference.positive?
                   "+#{@difference.valuation_difference}"
                 else
                   @difference.valuation_difference
                 end

    time_ago_string = "(#{time_ago_in_words(@difference.earliest_valuation_date + 1.day)} ago)" unless @difference.earliest_valuation_date.nil?

    <<~SUMMARY.strip
      ```
      #{@difference.hood_name} (#{@difference.house_count} Happy #{"House".pluralize(@difference.house_count)})

      #{short_date_format(@difference.earliest_valuation_date)}: #{currency_format(@difference.earliest_valuation)} #{time_ago_string}
      #{short_date_format(@difference.latest_valuation_date)}: #{currency_format(@difference.latest_valuation)}
      Difference:   #{currency_format(difference)} #{average_house_difference}
      ```
    SUMMARY
  end

  private

  def currency_format(num)
    self.class.number_to_currency(num)
  end

  def short_date_format(date)
    date.strftime(SHORT_DATE_FORMAT)
  end

  def time_ago_in_words(datetime)
    self.class.time_ago_in_words(datetime)
  end
end
