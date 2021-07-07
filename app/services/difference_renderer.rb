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
    ERB
      .new(File.read(template_path), trim_mode: "%<>")
      .result_with_hash(erb_hash)
  end

  private

  def erb_hash
    average_house_difference = if @difference.average_house_difference
                                 avg_diff_string = number_to_currency_with_direction_indicator(@difference.average_house_difference)
                                 "(#{avg_diff_string} avg/house)"
                               end

    {
      hood_name: @difference.hood_name,
      house_count: @difference.house_count,
      house_or_houses: "House".pluralize(@difference.house_count),
      average_house_price: number_to_currency(@difference.average_house_price),
      latest_valuation_date: short_date_format(@difference.latest_valuation_date),
      latest_valuation: number_to_currency(@difference.latest_valuation),
      difference_in_currency: number_to_currency(@difference.valuation_difference),
      earliest_valuation_date: @difference.earliest_valuation_date ? short_date_format(@difference.earliest_valuation_date) : nil,
      earliest_valuation: @difference.earliest_valuation ? number_to_currency(@difference.earliest_valuation) : nil,
      time_ago_since_earliest_valuation: @difference.earliest_valuation_date ? "(#{time_ago_in_words(@difference.earliest_valuation_date + 1.day)} ago)" : nil,
      average_house_difference: average_house_difference,
    }
  end

  def template_path
    Rails.root.join("app", "views", "templates", "difference_summary.md.erb")
  end

  def short_date_format(date)
    date.strftime(SHORT_DATE_FORMAT)
  end

  def number_to_currency_with_direction_indicator(number)
    if number.positive?
      "+#{number_to_currency(number)}"
    else
      number_to_currency(number)
    end
  end
end
