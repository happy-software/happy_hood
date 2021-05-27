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
        expect(mock_slack_client).to receive(:chat_postMessage).with(a_hash_including(
          text: "No changes for any HappyHood"
        ))

        described_class.send_daily_price_summary
      end
    end

    context "when the neighborhood had valuation changes" do
      before do
      end
      context "one of the neighborhoods does not have a different valuation" do
        it "does not include that neighborhood in the message" do

        end
      end

      context "a neighborhood that has dropped in valuation" do
        it "shows a negative sign to indicate a drop in price" do

        end
      end

      context "a neighborhood that has gone up in valuation" do
        it "shows a negative sign to indicate a drop in price" do

        end
      end
    end
  end
end
