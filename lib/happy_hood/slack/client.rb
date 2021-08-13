module HappyHood
  module Slack
    class Client
      DefaultSlackChannel = "#happy-hood".freeze
      DefaultIconEmoji = ":house_buildings:".freeze

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
