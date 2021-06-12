require "rails_helper"

describe DifferenceCalculator do
  describe "#differences" do
    context "when there are no neighborhoods passed in" do
      it "returns an empty list" do
        expect(described_class.new([], start_date: 1.day.ago, end_date: Date.today).differences).to be_empty
      end
    end

    context "when hoods are passed in" do
      it "generates a list of HoodDifference" do
        hoods = 3.times.map { |_| Hood.new }

        expect(described_class.new(hoods, start_date: nil, end_date: nil).differences).to all(be_an(HoodDifference))
      end

      it "generates a proper summary" do
        hood = Hood.create(name: "Schitt's Creek")
        hood.houses.create(price_history: {
          1.day.ago.strftime("%Y-%m-%d") => 300_000,
          Date.today.strftime("%Y-%m-%d") => 310_000,
        })
        hood.houses.create(price_history: {
          1.day.ago.strftime("%Y-%m-%d") => 280_000,
          Date.today.strftime("%Y-%m-%d") => 287_000,
        })

        instance = described_class.new([hood])

        differences = instance.differences

        expect(differences.size).to eq(1)

        difference = differences.first

        expect(difference).to have_attributes(
          hood_name: "Schitt's Creek",
          earliest_valuation: 580_000.00,
          latest_valuation: 597_000.00,
          house_count: 2,
          average_house_difference: 8_500.00
        )
      end
    end
  end
end
