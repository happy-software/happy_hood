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

        def self.house_prices_on(hood, date)
          hood.houses.map { |h| h.house_prices.on(date).last&.price }.compact.sum
        end

        def self.daily_message
          message = Hood.all.map { |hood| neighborhood_summary(hood) }.join("\n")
          {
            text:       message,
            icon_emoji: ':house_buildings:',
            channel:    '#happy-hood',
          }
        end

        def self.neighborhood_summary(hood)
          yesterdays_valuation = house_prices_on(hood, Date.yesterday)
          todays_valuation     = house_prices_on(hood, Date.today)
          difference           = todays_valuation&.-(yesterdays_valuation)

          "```"\
          "(#{hood.name}) - #{hood.houses.count} Happy Houses - (#{Date.today})\n"\
          "Yesterday: #{currency_format(yesterdays_valuation)}\n"\
          "Today:     #{currency_format(todays_valuation)} (Difference: #{currency_format(difference)})\n"\
          "```"
        end

        def self.currency_format(num)
          number_to_currency(num)
        end
    end
  end
end
