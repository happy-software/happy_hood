require "rails_helper"

describe DifferenceRenderer do
  describe "#render" do
    context "when a neighborhood does not have houses that were valuated on the same day" do
      it "posts a message saying no updates" do
        hood = Hood.create(name: "Schitt's Creek")
        hood.houses.new.add_valuation(1.day.ago, 25).save!
        hood.houses.new.add_valuation(2.day.ago, 26).save!

        difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
        rendered_diff = described_class.summarize_differences([difference])

        expect(rendered_diff).to eq("")
      end
    end

    context "when the neighborhood had valuation changes" do
      let(:hood) { Hood.create(name: "Schitt's Creek") }
      let(:hood2) { Hood.create(name: "Del Boca Vista") }

      context "one of the neighborhoods does not have a different valuation" do
        it "does not include that neighborhood in the message" do
          hood.houses.new
            .add_valuation(1.day.ago, 25)
            .add_valuation(Date.today, 25)
            .save!

          hood2.houses.new
            .add_valuation(1.day.ago, 0)
            .add_valuation(Date.today, 25)
            .save!

          differences = [
            HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today),
            HoodDifference.build_for(hood2, start_date: 1.day.ago, end_date: Date.today),
          ]

          rendered_diff = described_class.summarize_differences(differences)

          expect(rendered_diff).not_to match(a_string_including(hood.name))
          expect(rendered_diff).to match(a_string_including(hood2.name))
        end
      end

      context "when there is only one house" do
        it "does not show an average per house" do
          hood.houses.new
            .add_valuation(1.day.ago, 25)
            .add_valuation(Date.today, 24)
            .save!

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          expect(rendered_diff).not_to match(a_string_including("avg/house"))
        end
      end

      context "when a neighborhood that was just added has houses partially valuated" do
        it "posts a message without yesterday included" do
          hood.houses.new
            .add_valuation(Date.today, 24)
            .save!

          hood.houses.new
            .add_valuation(12.days.ago, 20)
            .add_valuation(Date.today, 24)
            .save!

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "#{Date.today.strftime("%b %d, %Y")}:    $48.00",
              "Difference:      $48.00",
              "(+$24.00 avg/house)",
              "Avg House Price: $24.00",
            )
          )
        end
      end

      context "when a neighborhood has houses that were valuated prior to yesterday and valuated today" do
        it "posts a message with the delta" do
          # The case when we stopped updating house prices for some reason
          # like running out of dynos
          hood.houses.new
            .add_valuation(12.days.ago, 20)
            .add_valuation(Date.today, 24)
            .save!

          hood.houses.new
            .add_valuation(12.days.ago, 20)
            .add_valuation(Date.today, 24)
            .save!

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          puts rendered_diff

          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "#{12.days.ago.strftime(DifferenceRenderer::SHORT_DATE_FORMAT)}:    $40.00",
              "#{Date.today.strftime(DifferenceRenderer::SHORT_DATE_FORMAT)}:    $48.00",
              "Difference:      $8.00",
              "Avg House Price: $24.00 (+$4.00 avg/house)",
            )
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
          rendered_diff = described_class.summarize_differences([difference])

          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "Difference:      -$5.00",
              "Avg House Price: $22.50 (-$2.50 avg/house)"
            )
          )
        end
      end

      context "a neighborhood that has gone up in valuation" do
        it "shows a positive sign to indicate an increase in price per house" do
          hood.houses.new
            .add_valuation(1.day.ago, 25)
            .add_valuation(Date.today, 25)
            .save!

          hood.houses.new
            .add_valuation(1.day.ago, 25)
            .add_valuation(Date.today, 420)
            .save!

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          # (new price - old price) / houses.size
          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "Difference:      $395.00",
              "Avg House Price: $222.50 (+$197.50 avg/house)"
            )
          )
        end
      end
    end
  end
end
