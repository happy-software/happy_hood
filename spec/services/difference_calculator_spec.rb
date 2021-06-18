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

        differences = described_class.new(hoods, start_date: nil, end_date: nil).differences
        expect(differences).to all(be_an(HoodDifference))
        expect(differences.size).to eq(3)
      end
    end
  end
end
