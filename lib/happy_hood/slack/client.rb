module HappyHood
  module Slack
    class Client
      def self.send_daily_price_summary(summary)
        three_day_valuation = house_prices_on(3.days.ago)
        two_day_valuation   = house_prices_on(2.days.ago)
        one_day_valuation   = house_prices_on(1.days.ago)

        formatted_three_day_valuation = Kernel::sprintf("%.2f", house_prices_on(3.days.ago))
        formatted_two_day_valuation   = Kernel::sprintf("%.2f", house_prices_on(2.days.ago))
        formatted_one_day_valuation   = Kernel::sprintf("%.2f", house_prices_on(1.days.ago))

        formatted_two_day_diff = Kernel::sprintf("%.2f",three_day_valuation-two_day_valuation)
        formatted_one_day_diff = Kernel::sprintf("%.2f",two_day_valuation-one_day_valuation)

        message = "Three Days Ago: $#{formatted_three_day_valuation}\n" \
        "Two Days Ago: $#{formatted_two_day_valuation} ($#{formatted_two_day_diff})\n" \
        "One Day Ago: $#{formatted_one_day_valuation} ($#{formatted_one_day_diff})"
      end

      private

      def self.house_prices_on(date)
        HousePrice.on(date).sum(:price)
      end
    end
  end
end
