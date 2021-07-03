require "rails_helper"
require "csv"

RSpec.describe OnboardingController, type: :request do
  describe "/onboard" do
    context "when a propert request is made" do
      it "creates a hood and any houses" do
        request_body = {
          entries: 3.times.map do |i|
            Hash[Hood::Onboarder::RequiredFields.collect { |key| [key, nil] }].tap do |new_entry|
              new_entry[:hood_name] = "Schitt's Creek"
              new_entry[:house_street_address] = "#{i} fake st"
              new_entry[:house_city] = "Chicago"
              new_entry[:house_zip_code] = "60601"
            end
          end
        }

        expect { post onboard_path, params: request_body, as: :json }
          .to change { Hood.count }.from(0).to(1)
          .and change { House.count }.from(0).to(3)
      end
    end
  end
end
