require "rails_helper"

describe HoodDifference do
  describe "attributes of an instance" do
    context "when there are no houses" do
      it "has empty attributes" do
        expect(described_class.new(Hood.new, start_date: 1.day.ago, end_date: Date.today)).to have_attributes(
          hood_name: nil,
          earliest_valuation: 0,
          earliest_valuation_date: nil,
          latest_valuation: 0,
          latest_valuation_date: nil,
          valuation_difference: 0,
          house_count: 0,
          average_house_difference: nil,
        )
      end
    end

    context "when there are houses" do
      context "when each house was valuated on the earliest valuation date" do
        it "has correct difference values" do
          hood = Hood.create(name: "Schitt's Creek")
          hood.houses.new
            .add_valuation(1.day.ago, 300_000)
            .add_valuation(Date.today, 310_000)
            .save!

          hood.houses.new
            .add_valuation(1.day.ago, 280_000)
            .add_valuation(Date.today, 287_000)
            .save!

          instance = described_class.new(hood, start_date: 1.day.ago, end_date: Date.today)

          expect(instance).to have_attributes(
            hood_name: "Schitt's Creek",
            earliest_valuation: 580_000.00,
            earliest_valuation_date: 1.day.ago.to_date,
            latest_valuation: 597_000.00,
            latest_valuation_date: Date.today,
            valuation_difference: 17_000.00,
            house_count: 2,
            average_house_difference: 8_500.00,
          )
        end
      end

      context "when all the houses have been valuated, but one was not valuated on the specified earliest valuation date" do
        it "looks back to an earlier date with correct difference values based" do
          hood = Hood.create(name: "Schitt's Creek")
          hood.houses.new
            .add_valuation(2.days.ago, 300_000)
            .add_valuation(Date.today, 310_000)
            .save!
          hood.houses.new
            .add_valuation(2.days.ago, 279_000)
            .add_valuation(1.day.ago, 280_000)
            .add_valuation(Date.today, 287_000)
            .save!

          instance = described_class.new(hood, start_date: 1.day.ago, end_date: Date.today)

          expect(instance).to have_attributes(
            hood_name: "Schitt's Creek",
            earliest_valuation: 579_000.00,
            earliest_valuation_date: 2.days.ago.to_date,
            latest_valuation: 597_000.00,
            latest_valuation_date: Date.today,
            valuation_difference: 18_000.00,
            house_count: 2,
            average_house_difference: 9_000.00,
          )
        end
      end

      context "when there is only one house" do
        it "has correct difference values" do
          hood = Hood.create(name: "Schitt's Creek")
          hood.houses.new
            .add_valuation(1.day.ago, 300_000)
            .add_valuation(Date.today, 310_000)
            .save!

          instance = described_class.new(hood, start_date: 1.day.ago, end_date: Date.today)

          expect(instance).to have_attributes(
            hood_name: "Schitt's Creek",
            earliest_valuation: 300_000.00,
            earliest_valuation_date: 1.day.ago.to_date,
            latest_valuation: 310_000.00,
            latest_valuation_date: Date.today,
            valuation_difference: 10_000.00,
            house_count: 1,
            average_house_difference: nil,
          )
        end
      end
    end
  end
end
