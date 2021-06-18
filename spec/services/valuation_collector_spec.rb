require "rails_helper"

describe ValuationCollector do
  describe "#perform" do
    context "when a house does not have a zpid" do
      it "raises an appropriate error" do
        house = House.new

        expect { described_class.new(house).perform }.to raise_error(
          ValuationCollectorError,
          a_string_including("does not have a zpid")
        )
      end
    end

    context "when a house has a zpid" do
      context "on a successful update" do
        it "saves the valuation to the house" do
          mock_zpid = "sriracha-zpid"
          hood = Hood.create
          house = hood.houses.create
          house.house_metadatum = HouseMetadatum.create(zpid: mock_zpid)

          mock_response = instance_double(Rubillow::Models::SearchResult,
                                          price: 20,
                                          success?: true)

          allow(Rubillow::HomeValuation).to receive(:zestimate).with({ zpid: mock_zpid }).and_return(mock_response)

          expect(house.valuation_on(Date.today)).to eq(0)

          described_class.new(house).perform

          expect(house.valuation_on(Date.today)).to eq(20)
        end
      end

      context "on a bad response from Rubillow client" do
        it "raises an appropriate error" do
          mock_zpid = "sriracha-zpid"
          house = House.new
          house.house_metadatum = HouseMetadatum.new(zpid: mock_zpid)

          mock_response = instance_double(Rubillow::Models::SearchResult,
                                          message: "Could not locate property or something",
                                          success?: false)

          allow(Rubillow::HomeValuation).to receive(:zestimate).with({ zpid: mock_zpid }).and_return(mock_response)

          expect(house.valuation_on(Date.today)).to eq(0)

          expect { described_class.new(house).perform }.to raise_error(
            ValuationCollectorError,
            a_string_including("Could not update House", "Could not locate property or something")
          )
        end
      end
    end
  end
end
