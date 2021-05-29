require "rails_helper"
require "rake"

# Load all rake tasks once, available for re-use in each example
Rails.application.load_tasks

describe "scheduler.rake rake tasks" do
  let(:task) { Rake::Task[task_name] }
  let(:task_name) { "my:rake:task" }

  after(:each) do
    # Reset the task's `already_invoked` state, letting you
    # re-execute the task with all dependencies
    task.reenable 
  end

  describe "generate_hood_onboarding_csv" do
    let(:task_name) { "generate_hood_onboarding_csv" }

    it "creates a csv with the correct headers" do
      Tempfile.create(["onboard_neighborhood", ".csv"]) do |tmp_file|
        allow(File).to receive(:open)
          .with(a_string_including("onboard_neighborhood.csv"), "w", a_hash_including(:universal_newline))
          .and_return(tmp_file)

        task.invoke

        expect(File.read(tmp_file.path).strip).to eq(NeighborhoodCsvHeaders.join(","))
      end
    end
  end

  describe "upload_neighborhood" do
    let(:task_name) { "upload_neighborhood" }

    context "without neighborhood data" do
      it "creates the neighborhood without houses" do
        csv_file_path = Rails.root.join("spec", "fixtures", "empty_onboarding_neighborhood.csv")

        csv_entries = CSV.read(csv_file_path, headers: true).map(&:to_h)
        neighborhood_names = csv_entries.map { |entry| entry["neighborhood_name"] }.uniq

        expect(Hood.where(name: neighborhood_names)).to be_empty
        expect(House.count).to eq(0)

        task.invoke(csv_file_path)

        hoods = Hood.where(name: neighborhood_names)
        expect(hoods.size).to eq(1)
        expect(hoods.first.houses.count).to eq(0)
      end
    end

    context "with neighborhood data" do
      it "creates each house provided" do
        csv_file_path = Rails.root.join("spec", "fixtures", "nonempty_onboarding_neighborhood.csv")

        csv_entries = CSV.read(csv_file_path, headers: true).map(&:to_h)
        neighborhood_names = csv_entries.map { |entry| entry["neighborhood_name"] }.uniq

        expect(Hood.where(name: neighborhood_names)).to be_empty
        expect(House.count).to eq(0)

        task.invoke(csv_file_path)

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
