class DifferenceRenderer
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

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
                                                     "+#{number_to_currency(@difference.average_house_difference)}"
                                                   else
                                                     number_to_currency(@difference.average_house_difference)
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

      #{short_date_format(@difference.earliest_valuation_date)}: #{number_to_currency(@difference.earliest_valuation)} #{time_ago_string}
      #{short_date_format(@difference.latest_valuation_date)}: #{number_to_currency(@difference.latest_valuation)}
      Difference:   #{number_to_currency(difference)} #{average_house_difference}
      ```
    SUMMARY
  end

  private

  def short_date_format(date)
    date.strftime(SHORT_DATE_FORMAT)
  end
end
