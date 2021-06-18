require "rails_helper"

describe Hood do
  describe "#valuation_before" do
    context "when there are no houses" do
      it "returns 0" do
        expect(Hood.new.valuation_before(Date.today)).to eq({ date: nil, valuation: 0 })
      end
    end

    context "when there are houses" do
      context "when the houses were valuated yesterday" do
        it "returns the sum of yesterdays valuation" do
          hood = Hood.create
          hood.houses.create(price_history: { 1.day.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 30, 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })
          hood.houses.create(price_history: { 1.day.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 20, 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })

          expect(hood.valuation_before(Date.today)).to eq({
            date: 1.day.ago.to_date,
            valuation: 30 + 20,
          })
        end
      end

      context "when only some of the houses were valuated yesterday" do
        it "returns the sum of the valuation on the date they were all valuated" do
          hood = Hood.create
          hood.houses.create(price_history: { 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })
          hood.houses.create(price_history: { 1.day.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 20, 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })

          expect(hood.valuation_before(Date.today)).to eq({
            date: 3.days.ago.to_date,
            valuation: 5 + 5,
          })
        end
      end
    end
  end

  describe "#valuation_on_or_before" do
    context "when there are no houses" do
      it "returns 0" do
        expect(Hood.new.valuation_on_or_before(Date.today)).to eq({ date: nil, valuation: 0 })
      end
    end

    context "when there are houses" do
      context "when the houses were valuated yesterday" do
        it "returns the sum of yesterdays valuation" do
          hood = Hood.create
          hood.houses.create(price_history: { 1.day.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 30, 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })
          hood.houses.create(price_history: { 1.day.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 20, 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })

          expect(hood.valuation_on_or_before(1.day.ago)).to eq({
            date: 1.day.ago.to_date,
            valuation: 30 + 20,
          })
        end
      end

      context "when only some of the houses were valuated yesterday" do
        it "returns the sum of the valuation on the date they were all valuated" do
          hood = Hood.create
          hood.houses.create(price_history: { 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })
          hood.houses.create(price_history: { 1.day.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 20, 3.days.ago.strftime(House::PRICE_HISTORY_DATE_FORMAT) => 5 })

          expect(hood.valuation_on_or_before(1.day.ago)).to eq({
            date: 3.days.ago.to_date,
            valuation: 5 + 5,
          })
        end
      end
    end
  end
end
