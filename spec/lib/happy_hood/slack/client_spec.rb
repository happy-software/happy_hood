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
          text: "No changes for any HappyHood"
        ))
      end
    end
    
    context "when there is a summary available" do
      it "posts a message with the differences" do
        mock_difference = instance_double(HoodDifference,
                                          empty?: false,
                                          hood_name: "Schitt's Creek",
                                          earliest_valuation: 5.00,
                                          earliest_valuation_date: 1.day.ago.to_date,
                                          latest_valuation: 10.00,
                                          latest_valuation_date: Date.today,
                                          house_count: 1,
                                          valuation_difference: 5.00,
                                          average_house_difference: nil
                                         )
        mock_calculator = instance_double(DifferenceCalculator, differences: [mock_difference])
        allow(DifferenceCalculator).to receive(:new).and_return(mock_calculator)

        described_class.send_daily_price_summary

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: a_string_including(
            "Schitt's Creek",
            "#{1.day.ago.strftime(DifferenceRenderer::SHORT_DATE_FORMAT)}: $5.00",
            "#{Date.today.strftime(DifferenceRenderer::SHORT_DATE_FORMAT)}: $10.00",
            "Difference:   $5.00",
          )
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
          text: "Could not calculate monthly difference"
        ))
      end
    end
    
    context "when there is a summary available" do
      it "posts a message with the differences" do
        mock_difference = instance_double(HoodDifference,
                                          empty?: false,
                                          hood_name: "Schitt's Creek",
                                          earliest_valuation: 5.00,
                                          earliest_valuation_date: 1.month.ago.to_date,
                                          latest_valuation: 10.00,
                                          latest_valuation_date: Date.today,
                                          house_count: 1,
                                          valuation_difference: 5.00,
                                          average_house_difference: nil
                                         )
        mock_calculator = instance_double(DifferenceCalculator, differences: [mock_difference])
        allow(DifferenceCalculator).to receive(:new).and_return(mock_calculator)

        described_class.send_daily_price_summary

        expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
          text: a_string_including(
            "Schitt's Creek",
            "#{1.month.ago.strftime(DifferenceRenderer::SHORT_DATE_FORMAT)}: $5.00",
            "#{Date.today.strftime(DifferenceRenderer::SHORT_DATE_FORMAT)}: $10.00",
            "Difference:   $5.00",
          )
        ))
      end
    end
  end
end
