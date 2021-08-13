require "rails_helper"
require_relative "#{Rails.root.join("lib", "happy_hood", "slack", "client")}"

describe HappyHood::Slack::Client do
  describe ".send_daily_price_summary" do
    let(:mock_slack_client) { instance_double(Slack::Web::Client) }

    before do
      allow(mock_slack_client).to receive(:chat_postMessage)
      allow(Slack::Web::Client).to receive(:new).and_return(mock_slack_client)
    end

    context "when the neighborhoods have not had any valuation changes" do
      it "posts a message saying no updates" do
        mock_difference = instance_double(HoodDifference, empty?: true)
        mock_calculator = instance_double(DifferenceCalculator, differences: [mock_difference])
        allow(DifferenceCalculator).to receive(:new).and_return(mock_calculator)

        described_class.send_daily_price_summary

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: "No changes for any HappyHood",
          icon_emoji: HappyHood::Slack::Client::DefaultIconEmoji,
          channel: HappyHood::Slack::Client::DefaultSlackChannel,
        ))
      end
    end
    
    context "when there is a summary available" do
      it "posts a message with the differences" do
        mocked_response = "A ton of houses updated!"
        allow(DifferenceRenderer).to receive(:summarize_differences).and_return(mocked_response)

        described_class.send_daily_price_summary

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: mocked_response,
          icon_emoji: HappyHood::Slack::Client::DefaultIconEmoji,
          channel: HappyHood::Slack::Client::DefaultSlackChannel,
        ))
      end
    end
  end

  describe ".send_monthly_price_summary" do
    let(:mock_slack_client) { instance_double(Slack::Web::Client) }

    before do
      allow(mock_slack_client).to receive(:chat_postMessage)
      allow(Slack::Web::Client).to receive(:new).and_return(mock_slack_client)
    end

    context "when the neighborhoods have not had any valuation changes" do
      it "posts a message saying no updates" do
        mock_difference = instance_double(HoodDifference, empty?: true)
        mock_calculator = instance_double(DifferenceCalculator, differences: [mock_difference])
        allow(DifferenceCalculator).to receive(:new).and_return(mock_calculator)

        described_class.send_monthly_price_summary

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: "Could not calculate monthly difference",
          icon_emoji: HappyHood::Slack::Client::DefaultIconEmoji,
          channel: HappyHood::Slack::Client::DefaultSlackChannel,
        ))
      end
    end
    
    context "when there is a summary available" do
      it "posts a message with the differences" do
        mocked_response = "A ton of houses updated!"
        allow(DifferenceRenderer).to receive(:summarize_differences).and_return(mocked_response)

        described_class.send_monthly_price_summary

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: mocked_response,
          icon_emoji: HappyHood::Slack::Client::DefaultIconEmoji,
          channel: HappyHood::Slack::Client::DefaultSlackChannel,
        ))
      end
    end
  end

  describe ".send_summary" do
    let(:mock_slack_client) { instance_double(Slack::Web::Client) }
    let(:start_date) { (Date.today - 1.day).beginning_of_quarter }
    let(:end_date) { (Date.today - 1.day).end_of_quarter }

    before do
      allow(mock_slack_client).to receive(:chat_postMessage)
      allow(Slack::Web::Client).to receive(:new).and_return(mock_slack_client)
    end

    context "when the neighborhoods have not had any valuation changes" do
      it "posts a message saying no updates" do
        mock_difference = instance_double(HoodDifference, empty?: true)
        mock_calculator = instance_double(DifferenceCalculator, differences: [mock_difference])
        allow(DifferenceCalculator).to receive(:new).and_return(mock_calculator)

        described_class.send_summary(start_date: start_date, end_date: end_date)

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: a_string_including("Could not calculate difference"),
          icon_emoji: HappyHood::Slack::Client::DefaultIconEmoji,
          channel: HappyHood::Slack::Client::DefaultSlackChannel,
        ))
      end
    end

    context "when there is a summary available" do
      it "posts a message with the differences" do
        mocked_response = "A ton of houses updated!"
        allow(DifferenceRenderer).to receive(:summarize_differences).and_return(mocked_response)

        described_class.send_summary(start_date: start_date, end_date: end_date)

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: mocked_response,
          icon_emoji: HappyHood::Slack::Client::DefaultIconEmoji,
          channel: HappyHood::Slack::Client::DefaultSlackChannel,
        ))
      end
    end
  end
end
