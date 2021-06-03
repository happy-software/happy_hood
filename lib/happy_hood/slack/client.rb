module HappyHood
  module Slack
    class Client
      extend ActionView::Helpers::NumberHelper
      extend ActionView::Helpers::DateHelper

      def self.send_daily_price_summary
        message = daily_message
        slack.chat_postMessage(message)
      end

      private

        def self.slack
          ::Slack::Web::Client.new
        end

        def self.daily_message
          neighborhood_differences = DailyDifferenceCalculator.new(Hood.all).differences
          messages  = summarize_differences(neighborhood_differences)

          messages = messages.empty? ? 'No changes for any HappyHood' : messages
          {
            text:       messages,
            icon_emoji: ':house_buildings:',
            channel:    '#happy-hood',
          }
        end


        def self.summarize_differences(differences)
          differences.reject { |d| d.valuation_difference.zero? }.map do |d|
            average_house_difference = if d.average_house_diff
              avg_diff_string = d.average_house_diff.positive? ? "+#{currency_format(d.average_house_diff)}" : currency_format(d.average_house_diff)

              "(#{avg_diff_string} avg/house)"
            end

            difference = d.valuation_difference.positive? ? "+#{d.valuation_difference}" : d.valuation_difference

            last_day_string = if d.last_valuation_date.nil? || d.last_valuation_date == 1.day.ago.to_date
              "Yesterday"
            else
              # we offset the time here a bit
              # time_ago_in_words(1.day.ago.to_date) == "2 days"
              # time_ago_in_words(1.day.ago.to_date + 1.day) == "1 day"
              "#{time_ago_in_words(d.last_valuation_date + 1.day)} ago"
            end

            <<~SUMMARY.strip
              ```
              #{d.name} (#{d.house_count} Happy #{"House".pluralize(d.house_count)})

              #{last_day_string}:   #{currency_format(d.last_valuation)}
              Today:      #{currency_format(d.todays_valuation)}
              Difference: #{currency_format(difference)} #{average_house_difference}
              ```
            SUMMARY
          end.join("\n")
        end

        def self.currency_format(num)
          number_to_currency(num)
        end
    end
  end
end
