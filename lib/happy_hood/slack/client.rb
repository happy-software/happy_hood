module HappyHood
  module Slack
    class Client
      DefaultSlackChannel = "#happy-hood".freeze
      DefaultIconEmoji = ":house_buildings:".freeze

      PostMessageDefaults = {
        icon_emoji: DefaultIconEmoji,
        channel: DefaultSlackChannel,
      }

      def self.send_summary(start_date:, end_date:, error_text: nil)
        differences = build_differences(start_date, end_date)

        slack_payload = { text: error_text || "Could not calculate difference for dates #{start_date} through #{end_date}" }

        if differences.any?
          slack_payload = { text: DifferenceRenderer.summarize_differences(differences) }
        end

        slack.chat_postMessage(PostMessageDefaults.merge(slack_payload))
      end

      def self.send_summary_using_blocks(summary_type: ,start_date:, end_date:, error_text: nil)
        differences = build_differences(start_date, end_date)

        slack_payload = { text: error_text || "Could not calculate difference for dates #{start_date} through #{end_date}" }

        if differences.any?
          slack_payload = { blocks: DifferenceBlockRenderer.summarize_differences(differences, summary_type: summary_type) }
        end

        slack.chat_postMessage(PostMessageDefaults.merge(slack_payload))
      end

      private

      def self.slack
        ::Slack::Web::Client.new
      end

      def self.build_differences(start_date, end_date)
        DifferenceCalculator
          .new(Hood.all, start_date: start_date, end_date: end_date)
          .differences
          .reject(&:empty?)
      end
    end
  end
end
