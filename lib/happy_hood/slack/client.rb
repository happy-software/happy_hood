module HappyHood
  module Slack
    class Client
      extend ActionView::Helpers::NumberHelper

      def self.send_daily_price_summary
        message = daily_message
        slack.chat_postMessage(message)
      end

      private

        def self.slack
          @slack ||= ::Slack::Web::Client.new
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
            "```"\
            "(#{d.name}) - #{d.house_count} Happy Houses - (#{d.valuation_date})\n"\
            "Yesterday: #{currency_format(d.yesterdays_valuation)}\n"\
            "Today:     #{currency_format(d.todays_valuation)} (Difference: #{currency_format(d.valuation_difference)})\n"\
            "```"
          end.join("\n")
        end

        def self.currency_format(num)
          number_to_currency(num)
        end
    end
  end
end
