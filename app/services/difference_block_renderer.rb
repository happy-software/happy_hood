class DifferenceBlockRenderer
  extend ActionView::Helpers::NumberHelper

  DIVIDER_HASH = { type: "divider" }.freeze
  MARKDOWN_TYPE = "mrkdwn".freeze
  SECTION_TYPE = "section".freeze

  def self.summarize_differences(hood_differences, summary_type:)
    [].tap do |blocks|
      blocks << {
        type: SECTION_TYPE,
        text: {
          type: MARKDOWN_TYPE,
          text: ":wave: Hello team! Here is your *#{summary_type}* summary for #{hood_differences.size} Happy #{"Hood".pluralize(hood_differences.size)}.",
        }
      }

      blocks << DIVIDER_HASH

      hood_differences.each do |difference|
        text = if first_time_posting?(difference)
                 first_time_hood_text(difference)
               elsif difference.valuation_difference.positive?
                 positive_hood_text(difference)
               else
                 negative_hood_text(difference)
               end

        blocks << {
          type: SECTION_TYPE,
          text: {
            type: MARKDOWN_TYPE,
            text: text
          }
        }

        blocks << DIVIDER_HASH
      end
    end
  end

  def self.first_time_posting?(difference)
    difference.earliest_valuation_date.blank?
  end
  def self.hood_name_and_house_count(difference)
    "*#{difference.hood_name}* (#{difference.house_count} Happy #{"House".pluralize(difference.house_count)})"
  end

  def self.first_time_hood_text(difference)
    text = ":house_buildings: #{hood_name_and_house_count(difference)} "
    text += "did not have a previous valuation. It is currently valuated at *#{number_to_currency(difference.latest_valuation)}*."

    if difference.house_count > 1
      text += "\n\nThe average Happy House price is *#{number_to_currency(difference.average_house_price)}*."
    end

    text
  end

  def self.positive_hood_text(difference)
    text = ":chart_with_upwards_trend: #{hood_name_and_house_count(difference)} "
    text += "*went up* in price by *#{number_to_currency(difference.valuation_difference)}*, increasing in valuation to *#{number_to_currency(difference.latest_valuation)}*."

    if difference.house_count > 1
      text += "\n\nThe average Happy House price *increased* by "
      text += "*#{number_to_currency(difference.average_house_difference)}*, bringing the average cost to "
      text += "*#{number_to_currency(difference.average_house_price)}*."
    end

    text
  end

  def self.negative_hood_text(difference)
    text = ":chart_with_downwards_trend: #{hood_name_and_house_count(difference)} "
    text += "*went down* in price by *#{number_to_currency(difference.valuation_difference.abs)}*, decreasing in valuation to *#{number_to_currency(difference.latest_valuation)}*."

    if difference.house_count > 1
      text += "\n\nThe average Happy House price *decreased* by "
      text += "*#{number_to_currency(difference.average_house_difference.abs)}*, bringing the average cost to "
      text += "*#{number_to_currency(difference.average_house_price)}*."
    end

    text
  end
end
