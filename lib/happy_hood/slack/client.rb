module HappyHood
  module Slack
    class Client
      def self.send_daily_price_summary
        message = daily_message
        slack.chat_postMessage(message)
      end

      private

        def self.slack
          @slack ||= ::Slack::Web::Client.new
        end

        def self.house_prices_on(date)
          HousePrice.on(date).sum(:price)
        end

        def self.daily_message
          yesterdays_valuation = house_prices_on(Date.yesterday)
          todays_valuation     = house_prices_on(Date.today)

          message =
            "Hood Valuation for #{Date.today}\n"\
            "```"\
            "Yesterday: $#{currency_format(yesterdays_valuation)}\n"\
            "Today:     $#{currency_format(todays_valuation)} ($#{currency_format(yesterdays_valuation-todays_valuation)})"\
            "```"
          {
            text:       message,
            icon_emoji: ":house_buildings:",
            channel:    '#happy-hood',
          }
        end

        def self.currency_format(num)
          include ActionView::Helpers::NumberHelper
          number_to_currency(num)
        end
    end
  end
end
