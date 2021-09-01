class DifferenceBlockRenderer
  DIVIDER_JSON = { type: "divider" }.freeze
  MARKDOWN_TYPE = "mrkdwn".freeze
  SECTION_TYPE = "section".freeze

  def self.summarize_differences(hood_differences, summary_type:)
    [].tap do |blocks|
      blocks << {
        type: SECTION_TYPE,
        text: {
          type: MARKDOWN_TYPE,
          text: "Hello team :wave:, here is your *#{summary_type}* summary for #{hood_differences.size} Happy Hoods.",
        }
      }

      blocks << DIVIDER_JSON

      hood_differences.each do |difference|
        text = difference.valuation_difference.positive? ? positive_hood_text(difference) : negative_hood_text(difference)

        blocks << {
          type: SECTION_TYPE,
          text: {
            type: MARKDOWN_TYPE,
            text: text
          }
        }

        blocks << DIVIDER_JSON
      end
    end
  end

  def self.positive_hood_text(difference)
    text = ":chart_with_upwards_trend: *#{difference.hood_name}* (#{difference.house_count} Happy #{"House".pluralize(difference.house_count)}) "
    text += "*went up* in price by *#{number_to_currency(difference.valuation_difference)}* increasing in valuation to *#{number_to_currency(difference.latest_valuation)}*."

    if difference.house_count > 1
      text += "The average Happy House price *increased* by "
      text += "*#{number_to_currency(difference.average_house_difference)}*, bringing the average cost to "
      text += "*#{number_to_currency(difference.average_house_price)}*"
    end

    text
  end

  def self.negative_hood_text(difference)
    text = ":chart_with_downwards_trend: *#{difference.hood_name}* (#{difference.house_count} Happy #{"House".pluralize(difference.house_count)}) "
    text += "*went down* in price by *#{number_to_currency(difference.valuation_difference)}* decreasing in valuation to *#{number_to_currency(difference.latest_valuation)}*."

    if difference.house_count > 1
      text += "The average Happy House price *decreased* by "
      text += "*#{number_to_currency(difference.average_house_difference)}*, bringing the average cost to "
      text += "*#{number_to_currency(difference.average_house_price)}*"
    end

    text
  end
end
