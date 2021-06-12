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


    # context "when a neighborhood does not have houses that were valuated on the same day" do
    #   it "posts a message saying no updates" do
    #     hood = Hood.create(name: "Schitt's Creek")
    #     hood.houses.create(price_history: {
    #       string_date(1.day.ago) => 25,
    #     })

    #     hood.houses.create(price_history: {
    #       string_date(2.day.ago) => 26
    #     })

    #     described_class.send_daily_price_summary

    #     expect(mock_slack_client).to have_received(:chat_postMessage).with(a_hash_including(
    #       text: "No changes for any HappyHood"
    #     ))
    #   end
    # end

    # context "when the neighborhood had valuation changes" do
    #   let(:hood) { Hood.create(name: "Schitt's Creek") }
    #   let(:hood2) { Hood.create(name: "Del Boca Vista") }

    #   context "one of the neighborhoods does not have a different valuation" do
    #     it "does not include that neighborhood in the message" do
    #       hood.houses.create(price_history: {
    #         string_date(1.day.ago) => 25,
    #         string_date(Date.today) => 25
    #       })

    #       hood2.houses.create(price_history: {
    #         string_date(1.day.ago) => 0,
    #         string_date(Date.today) => 25
    #       })

    #       described_class.send_daily_price_summary

    #       expect(mock_slack_client).not_to have_received(:chat_postMessage).with(
    #         a_hash_including(
    #           text: a_string_including(hood.name)
    #         )
    #       )

    #       expect(mock_slack_client).to have_received(:chat_postMessage).with(
    #         a_hash_including(
    #           text: a_string_including(hood2.name)
    #         )
    #       )
    #     end
    #   end

    #   context "when there is only one house" do
    #     it "does not show an average per house" do
    #       hood.houses.create(price_history: {
    #         string_date(1.day.ago) => 25,
    #         string_date(Date.today) => 24,
    #       })

    #       described_class.send_daily_price_summary

    #       expect(mock_slack_client).not_to have_received(:chat_postMessage).with(
    #         a_hash_including(
    #           text: a_string_including("avg/house")
    #         )
    #       )
    #     end
    #   end

    #   context "when a neighborhood has houses that were valuated prior to yesterday and valuated today" do
    #     it "posts a message with the delta" do
    #       # The case when we stopped updating house prices for some reason
    #       # like running out of dynos
    #       hood.houses.create(price_history: {
    #         string_date(12.days.ago) => 20,
    #         string_date(Date.today) => 24,
    #       })
    #       hood.houses.create(price_history: {
    #         string_date(12.days.ago) => 20,
    #         string_date(Date.today) => 24,
    #       })

    #       described_class.send_daily_price_summary

    #       expect(mock_slack_client).to have_received(:chat_postMessage).with(
    #         a_hash_including(
    #           text: a_string_including(
    #             hood.name,
    #             "#{12.days.ago.strftime("%b %d, %Y")}: $40.00 (12 days ago)",
    #             "Difference:   $8.00",
    #             "(+$4.00 avg/house)",
    #           )
    #         )
    #       )
    #     end
    #   end

    #   context "a neighborhood that has dropped in valuation" do
    #     it "shows a negative sign to indicate a drop in price" do
    #       hood.houses.create(price_history: {
    #         string_date(1.day.ago) => 25,
    #         string_date(Date.today) => 25,
    #       })

    #       hood.houses.create(price_history: {
    #         string_date(1.day.ago) => 25,
    #         string_date(Date.today) => 20
    #       })

    #       described_class.send_daily_price_summary

    #       expect(mock_slack_client).to have_received(:chat_postMessage).with(
    #         a_hash_including(
    #           text: a_string_including(hood.name, "Difference:   -$5.00", "(-$2.50 avg/house)")
    #         )
    #       )
    #     end
    #   end

    #   context "a neighborhood that has gone up in valuation" do
    #     it "shows a positive sign to indicate an increase in price per house" do
    #       hood.houses.create(price_history: {
    #         string_date(1.day.ago) => 25,
    #         string_date(Date.today) => 25,
    #       })

    #       hood.houses.create(price_history: {
    #         string_date(1.day.ago) => 25,
    #         string_date(Date.today) => 420
    #       })

    #       described_class.send_daily_price_summary

    #       # (new price - old price) / houses.size
    #       expect(mock_slack_client).to have_received(:chat_postMessage).with(
    #         a_hash_including(
    #           text: a_string_including(hood.name, "Difference:   $395.00", "(+$197.50 avg/house)")
    #         )
    #       )
    #     end
    #   end
    # end
  end
end
