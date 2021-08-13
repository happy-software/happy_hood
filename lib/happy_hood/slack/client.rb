module HappyHood
  module Slack
    class Client
      DefaultSlackChannel = "#happy-hood".freeze
      DefaultIconEmoji = ":house_buildings:".freeze

      def self.send_daily_price_summary
        message = build_message_for(1.day.ago, Date.today)

        if message.empty?
          message = "No changes for any HappyHood"
        end

        slack.chat_postMessage({
          text: message,
          icon_emoji: DefaultIconEmoji,
          channel: DefaultSlackChannel,
        })
      end

      def self.send_monthly_price_summary
        message = build_message_for((Date.today.beginning_of_month - 1.month), Date.today)

        if message.empty?
          message = "Could not calculate monthly difference"
        end

        slack.chat_postMessage({
          text: message,
          icon_emoji: DefaultIconEmoji,
          channel: DefaultSlackChannel,
        })
      end

      def self.send_summary(start_date:, end_date:)
        message = build_message_for(start_date, end_date)

        if message.empty?
          message = "Could not calculate difference for dates #{start_date} through #{end_date}"
        end

        slack.chat_postMessage({
          text: message,
          icon_emoji: DefaultIconEmoji,
          channel: DefaultSlackChannel,
        })
      end

      private

      def self.slack
        ::Slack::Web::Client.new
      end

      def self.build_message_for(start_date, end_date)
        differences = DifferenceCalculator.new(Hood.all, start_date: start_date, end_date: end_date).differences

        DifferenceRenderer.summarize_differences(differences)
      end
    end
  end
end
