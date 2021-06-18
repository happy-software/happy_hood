require "rails_helper"

describe DifferenceRenderer do
  def string_date(date)
    date.strftime(House::PRICE_HISTORY_DATE_FORMAT)
  end

  describe "#render" do
    context "when a neighborhood does not have houses that were valuated on the same day" do
      it "posts a message saying no updates" do
        hood = Hood.create(name: "Schitt's Creek")
        hood.houses.create(price_history: {
          string_date(1.day.ago) => 25,
        })

        hood.houses.create(price_history: {
          string_date(2.day.ago) => 26
        })

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
          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 25
          })

          hood2.houses.create(price_history: {
            string_date(1.day.ago) => 0,
            string_date(Date.today) => 25
          })

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
          hood.houses.create(price_history: {
            string_date(1.day.ago) => 25,
            string_date(Date.today) => 24,
          })

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          expect(rendered_diff).not_to match(a_string_including("avg/house"))
        end
      end

      context "when a neighborhood has houses that were valuated prior to yesterday and valuated today" do
        it "posts a message with the delta" do
          # The case when we stopped updating house prices for some reason
          # like running out of dynos
          hood.houses.create(price_history: {
            string_date(12.days.ago) => 20,
            string_date(Date.today) => 24,
          })
          hood.houses.create(price_history: {
            string_date(12.days.ago) => 20,
            string_date(Date.today) => 24,
          })

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "#{12.days.ago.strftime("%b %d, %Y")}: $40.00 (12 days ago)",
              "Difference:   $8.00",
              "(+$4.00 avg/house)",
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

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "Difference:   -$5.00",
              "(-$2.50 avg/house)"
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

          difference = HoodDifference.build_for(hood, start_date: 1.day.ago, end_date: Date.today)
          rendered_diff = described_class.summarize_differences([difference])

          # (new price - old price) / houses.size
          expect(rendered_diff).to match(
            a_string_including(
              hood.name,
              "Difference:   $395.00",
              "(+$197.50 avg/house)"
            )
          )
        end
      end
    end
  end
end
