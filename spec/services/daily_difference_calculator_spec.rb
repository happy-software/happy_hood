require "rails_helper"

describe DailyDifferenceCalculator do
  describe "#differences" do
    context "when there are no neighborhoods passed in" do
      it "returns an empty list" do
        expect(described_class.new([]).differences).to be_empty
      end
    end

    context "when hoods are passed in" do
      it "generates a list of HoodSummary" do
        hoods = 3.times.map { |_| Hood.new }

        expect(described_class.new(hoods).differences).to all(be_an(DailyDifferenceCalculator::HoodSummary))
      end

      it "generates a proper summary" do
        hood = Hood.create(name: "Schitt's Creek")
        hood.houses.new
          .add_valuation(1.day.ago, 300_000)
          .add_valuation(Date.today, 310_000)
          .save!
        hood.houses.new
          .add_valuation(1.day.ago, 280_000)
          .add_valuation(Date.today, 287_000)
          .save!

        instance = described_class.new([hood])

        differences = instance.differences

        expect(differences.size).to eq(1)

        difference = differences.first

        expect(difference.name).to eq("Schitt's Creek")
        expect(difference.last_valuation).to eq(580_000.00)
        expect(difference.todays_valuation).to eq(597_000.00)
        expect(difference.house_count).to eq(2)
        expect(difference.average_house_diff).to eq(8_500.00)
      end
    end
  end
end
