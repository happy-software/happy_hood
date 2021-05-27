require_relative "#{Rails.root.join("lib", "happy_hood", "slack", "client")}"

describe HappyHood::Slack::Client do
  def string_date(date)
    date.strftime("%Y-%m-%d")
  end

  describe ".send_daily_price_summary" do
    let(:mock_slack_client) { instance_double(Slack::Web::Client) }

    before do
      allow(mock_slack_client).to receive(:chat_postMessage)
      allow(Slack::Web::Client).to receive(:new).and_return(mock_slack_client)
    end

    context "when the neighborhoods have not had any valuation changes" do
      it "posts a message saying no updates" do
        expect(mock_slack_client).to receive(:chat_postMessage).with(a_hash_including(
          text: "No changes for any HappyHood"
        ))

        described_class.send_daily_price_summary
      end
    end

    context "when the neighborhood had valuation changes" do
      let(:hood) { Hood.create(name: "Schitt's Creek") }
      let(:hood2) { Hood.create(name: "Del Boca Vista") }

      context "one of the neighborhoods does not have a different valuation" do
        it "does not include that neighborhood in the message" do
          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 25
          })

          hood2.houses.create(price_history: {
            string_date(1.day.ago) => 0,
            string_date(Date.today) => 25
          })

          described_class.send_daily_price_summary

          expect(mock_slack_client).not_to have_received(:chat_postMessage).with(
            a_hash_including(
              text: a_string_including(hood.name)
            )
          )

          expect(mock_slack_client).to have_received(:chat_postMessage).with(
            a_hash_including(
              text: a_string_including(hood2.name)
            )
          )
        end
      end

      context "when there is only one house" do
        it "does not show an average per house" do
          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 24,
          })

          described_class.send_daily_price_summary

          expect(mock_slack_client).not_to have_received(:chat_postMessage).with(
            a_hash_including(
              text: a_string_including("avg/house")
            )
          )
        end
      end

      context "a neighborhood that has dropped in valuation" do
        it "shows a negative sign to indicate a drop in price" do
          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 25,
          })

          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 20
          })

          described_class.send_daily_price_summary

          expect(mock_slack_client).to have_received(:chat_postMessage).with(
            a_hash_including(
              text: a_string_including(hood.name, "Difference: -$5.00", "-$2.50 avg/house")
            )
          )
        end
      end

      context "a neighborhood that has gone up in valuation" do
        it "shows a positive sign to indicate an increase in price per house" do
          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 25,
          })

          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 420
          })

          described_class.send_daily_price_summary

          # (new price - old price) / houses.size
          expect(mock_slack_client).to have_received(:chat_postMessage).with(
            a_hash_including(
              text: a_string_including(hood.name, "Difference: $395.00", "(+$197.50 avg/house)")
            )
          )
        end
      end
    end
  end
end
