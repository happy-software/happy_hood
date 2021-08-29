require "rails_helper"

describe ZpidCollector do
  describe "#get_zpid" do
    subject { described_class.new(search_details).get_zpid }
    let(:search_details) do
      {
        city: "Salt Lake City",
        state: "UT",
        zip_code: "84044",
        street_address: "123 Fake St"
      }
    end
    it 'should make a request to zillow' do
      expect(Rubillow::HomeValuation).to receive(:search_results).with(
        {
          address: search_details[:street_address],
          citystatezip: "#{search_details[:city]}, #{search_details[:state]} #{search_details[:zip_code]}"
        }
      )
      subject
    end
  end

  describe ".fill_missing_zpids" do
    subject(:fill_missing_zpids) { described_class.fill_missing_zpids }
    context "when there are no houses to update" do
      it "returns a result with a count" do
        expect(fill_missing_zpids)
          .to be_a(
            ZpidCollectorResult
          ).and have_attributes(
            updated_count: 0,
            total_houses: 0
          )
      end
    end

    context "when only some houses to update" do
      let(:hood)   { Hood.create }
      let(:house1) { hood.houses.create(address: { street_address: "123" }, house_metadatum: HouseMetadatum.new) }
      let(:house2) { hood.houses.create(address: { street_address: "abc" }, house_metadatum: HouseMetadatum.new) }
      let(:success_mock) { double(Rubillow::Models::SearchResult, success?: true, zpid: "my-zpid-from-zillow") }
      let(:failure_mock) { double(Rubillow::Models::SearchResult, success?: false, message: "house is a trashbin") }

      before { house1; house2; }

      context "when they all update" do
        before { allow(Rubillow::HomeValuation).to receive(:search_results).and_return(success_mock) }

        it "updates all the zpids" do
          expect(fill_missing_zpids).to have_attributes(updated_count: 2, total_houses: 2)
          expect(house1.reload.zpid).to eq("my-zpid-from-zillow")
          expect(house2.reload.zpid).to eq("my-zpid-from-zillow")
        end
      end

      context "when one of the houses to update fails" do
        before do
          allow(Rubillow::HomeValuation).to receive(:search_results)
                                              .with(hash_including(address: house1.street_address))
                                              .and_return(success_mock)
          allow(Rubillow::HomeValuation).to receive(:search_results)
                                              .with(hash_including(address: house2.street_address))
                                              .and_return(failure_mock)
        end

        it "updates the other house's zpid" do
          expect(fill_missing_zpids).to have_attributes(updated_count: 1, total_houses: 2)

          expect(house1.reload.zpid).to eq("my-zpid-from-zillow")
          expect(house2.reload.zpid).to be_nil
        end
      end

      context "when zillow does not have data for the houses" do
        before { allow(Rubillow::HomeValuation).to receive(:search_results).and_return(failure_mock) }
        it "does not update any houses" do
          expect(fill_missing_zpids).to have_attributes(updated_count: 0, total_houses: 2)
        end
      end
    end
  end
end
