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

    let(:hood_name) { "Schitt's Creek" }
    let(:hood_zip_code) { "13459" }

    context "without neighborhood data" do
      it "creates the neighborhood without houses" do
        neighborhood_data = []

        expect(Hood.find_by(name: hood_name)).to be_nil

        expect { task.invoke(hood_name, hood_zip_code, neighborhood_data) }.not_to change { House.count }

        expect(Hood.find_by(name: hood_name)).to be_an_instance_of(Hood)
          .and have_attributes(name: hood_name, zip_code: hood_zip_code)
      end
    end

    context "with neighborhood data" do
      it "creates each house provided" do
        expect(Hood.find_by(name: hood_name)).to be_nil
        expect(House.count).to eq(0)

        task.invoke("Schitt's Creek", "33634", [
          ["8106 Muddy Pines Pl", "Tampa", "FL", "33635", "3", "2.5", "1872", "2"],
          ["8108 Muddy Pines Pl", "Tampa", "FL", "33635", "3", "2.5", "1816", "1"],
          ["8110 Muddy Pines Pl", "Tampa", "FL", "33635", "3", "2.5", "1584", "1"]
        ])

        hood = Hood.find_by(name: hood_name)
        expect(hood).not_to be_nil
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
