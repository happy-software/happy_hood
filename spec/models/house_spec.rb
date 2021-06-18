require "rails_helper"

describe House do
  describe "#valuation_on" do
    it "correctly returns a proper valuation" do
      date = Date.today
      house = House.new
      house.price_history[date.strftime(House::PRICE_HISTORY_DATE_FORMAT)] = 20

      expect(house.valuation_on(1.day.ago)).to eq(0)
      expect(house.valuation_on(date)).to eq(20)
    end
  end

  describe "#add_valuation" do
    it "is chainable" do
      date = 1.day.ago

      house = House.new
      house.add_valuation(date, 20)
      house.add_valuation(date, 10)
      house.add_valuation(date, 42)

      house2 = House.new
        .add_valuation(date, 20)
        .add_valuation(date, 10)
        .add_valuation(date, 42)

      expect(house.price_history).to eq(house2.price_history)
    end

    context "when there hasn't been a valuation" do
      it "creates a valuation" do
        house = House.new
        house.add_valuation(Date.today, 20)

        expect(house.valuation_on(Date.today)).to eq(20)
      end
    end

    context "when two updates happen on the same day" do
      it "keeps the last update" do
        date = Date.today

        house = House.new
          .add_valuation(date, 20)
          .add_valuation(date, 10)
          .add_valuation(date, 42)

        expect(house.valuation_on(date)).to eq(42)
      end
    end
  end
end
