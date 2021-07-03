require "rails_helper"
require "csv"

describe Hood::Onboarder do
  describe ".run" do
    context "with a bad csv" do
      it "does not create a hood" do
        Tempfile.create(["bad", ".csv"]) do |tmp_file|
          tmp_file.write "my,bad,headers,heh,heh,heh"
          tmp_file.rewind

          csv_entries = CSV.read(tmp_file.path, headers: true, header_converters: :symbol).map(&:to_h)

          expect { described_class.run(csv_entries) }.not_to change { Hood.count }
        end
      end
    end

    context "without neighborhood data" do
      it "creates the neighborhood without houses" do
        csv_file_path = Rails.root.join("spec", "fixtures", "empty_onboarding_neighborhood.csv")

        csv_entries = CSV.read(csv_file_path, headers: true, header_converters: :symbol).map(&:to_h)
        neighborhood_names = csv_entries.map { |entry| entry[:hood_name] }.uniq

        expect(Hood.where(name: neighborhood_names)).to be_empty
        expect(House.count).to eq(0)

        described_class.run(csv_entries)

        hoods = Hood.where(name: neighborhood_names)
        expect(hoods.size).to eq(1)
        expect(hoods.first.houses.count).to eq(0)
      end
    end

    context "with neighborhood data" do
      it "creates each house provided" do
        csv_file_path = Rails.root.join("spec", "fixtures", "nonempty_onboarding_neighborhood.csv")

        csv_entries = CSV.read(csv_file_path, headers: true, header_converters: :symbol).map(&:to_h)
        neighborhood_names = csv_entries.map { |entry| entry[:hood_name] }.uniq

        expect(Hood.where(name: neighborhood_names)).to be_empty
        expect(House.count).to eq(0)

        described_class.run(csv_entries)

        hoods = Hood.where(name: neighborhood_names)
        expect(hoods.size).to eq(1)

        hood = hoods.first
        expect(hood.houses.count).to eq(3)
        expect(hood.houses.map(&:address)).to include(
          hash_including("city" => "Tampa", "state" => "FL", "street_address" => "8106 Muddy Pines Pl", "zip_code" => "33635"),
          hash_including("city" => "Tampa", "state" => "FL", "street_address" => "8108 Muddy Pines Pl", "zip_code" => "33635"),
          hash_including("city" => "Tampa", "state" => "FL", "street_address" => "8110 Muddy Pines Pl", "zip_code" => "33635"),
        )
      end
    end

  end
end
