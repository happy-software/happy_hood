require "rails_helper"

describe DifferenceBlockRenderer do
  describe "#render" do
    context "when the neighborhood had valuation changes" do
      let(:hood) { Hood.create(name: "Schitt's Creek") }
      let(:hood2) { Hood.create(name: "Del Boca Vista") }

      context "when a neighborhood that was just added has houses partially valuated" do
        it "posts a message without yesterday included" do
          hood.houses.new
            .add_valuation(Date.today, 24)
            .save!

          hood2.houses.new
            .add_valuation(12.days.ago, 50)
            .add_valuation(Date.today, 50)
            .save!

          hood2.houses.new
            .add_valuation(12.days.ago, 20)
            .add_valuation(Date.today, 24)
            .save!

          differences = [
            HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today),
            HoodDifference.build_for(hood2, start_date: 1.day.ago, end_date: Date.today),
          ]

          rendering = described_class.summarize_differences(differences, summary_type: :daily)

          expect(rendering).to contain_exactly(
            {
              type: described_class::SECTION_TYPE,
              text: {
                type: described_class::MARKDOWN_TYPE,
                text: ":wave: Hello team! Here is your *daily* summary for 2 Happy Hoods.",
              },
            },
            described_class::DIVIDER_HASH,
            {
              type: described_class::SECTION_TYPE,
              text: {
                type: described_class::MARKDOWN_TYPE,
                text: a_string_including(
                  hood.name,
                  "did not have a previous valuation.",
                  "It is currently valuated at",
                  "$24.00",
                ),
              },
            },
            described_class::DIVIDER_HASH,
            {
              type: described_class::SECTION_TYPE,
              text: {
                type: described_class::MARKDOWN_TYPE,
                text: a_string_including(
                  hood2.name,
                  "went up",
                  "in price by",
                  "$4.00",
                  "increasing in valuation to",
                  "$74.00",
                  "The average Happy House price",
                  "increased",
                  "$2.00",
                  "bringing the average cost to",
                  "$37.00",
                ),
              },
            },
            described_class::DIVIDER_HASH,
          )
        end
      end

      context "a neighborhood that has dropped in valuation" do
        it "shows a negative sign to indicate a drop in price" do
          hood.houses.new
            .add_valuation(1.day.ago, 25)
            .add_valuation(Date.today, 25)
            .save!

          hood.houses.new
            .add_valuation(1.day.ago, 25)
            .add_valuation(Date.today, 20)
            .save!

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendering = described_class.summarize_differences([difference], summary_type: :daily)

          expect(rendering).to contain_exactly(
            {
              type: described_class::SECTION_TYPE,
              text: {
                type: described_class::MARKDOWN_TYPE,
                text: ":wave: Hello team! Here is your *daily* summary for 1 Happy Hood.",
              },
            },
            described_class::DIVIDER_HASH,
            {
              type: described_class::SECTION_TYPE,
              text: {
                type: described_class::MARKDOWN_TYPE,
                text: a_string_including(
                  hood.name,
                  "went down",
                  "in price by",
                  "$5.00",
                  "decreasing in valuation to",
                  "$45.00",
                  "The average Happy House price",
                  "decreased",
                  "$2.50",
                  "bringing the average cost to",
                  "$22.50",
                ),
              },
            },
            described_class::DIVIDER_HASH,
          )
        end
      end
    end
  end
end
