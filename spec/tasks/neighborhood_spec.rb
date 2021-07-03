require "rails_helper"
require "rake"

describe "neighborhood.rake rake tasks" do
  let(:task) { Rake::Task[task_name] }
  let(:task_name) { "my:rake:task" }

  after(:each) do
    # Reset the task's `already_invoked` state, letting you
    # re-execute the task with all dependencies
    task.reenable 
  end

  describe "generate_hood_onboarding_csv" do
    let(:task_name) { "neighborhood:generate_onboarding_csv" }

    it "creates a csv with the correct headers" do
      Tempfile.create(["onboard_neighborhood", ".csv"]) do |tmp_file|
        allow(File).to receive(:open)
          .with(a_string_including("onboard_neighborhood.csv"), "w", a_hash_including(:universal_newline))
          .and_return(tmp_file)

        task.invoke

        expect(File.read(tmp_file.path).strip).to eq(Hood::Onboarder::RequiredFields.join(","))
      end
    end
  end

  describe "upload_neighborhood" do
    let(:task_name) { "neighborhood:upload" }

    context "with a bad csv" do
      it "raises an error" do
        Tempfile.create(["bad", ".csv"]) do |tmp_file|
          tmp_file.write "my,bad,headers,heh,heh,heh"
          tmp_file.rewind

          expect { task.invoke(tmp_file.path) }.to raise_error(ArgumentError, /does not have valid headers./)
        end
      end
    end

    it "invokes the onboarder and creates houses" do
      csv_file_path = Rails.root.join("spec", "fixtures", "nonempty_onboarding_neighborhood.csv")

      expect(Hood::Onboarder).to receive(:run).and_call_original

      expect { task.invoke(csv_file_path) }
        .to change { Hood.count }.from(0).to(1)
        .and change { House.count }.from(0).to(3)
    end
  end
end
