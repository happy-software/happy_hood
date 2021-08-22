require "rails_helper"
require "csv"

RSpec.describe OnboardingController, type: :request do
  describe "/onboard" do
    let(:request_body) {
      {
          entries: 3.times.map do |i|
            Hash[Hood::Onboarder::RequiredFields.collect { |key| [key, nil] }].tap do |new_entry|
              new_entry[:hood_name] = "Schitt's Creek"
              new_entry[:house_street_address] = "#{i} fake st"
              new_entry[:house_city] = "Chicago"
              new_entry[:house_zip_code] = "60601"
            end
          end
        }
    }

    it "returns a 404 when the user is not authorized" do
      post onboard_path, params: request_body, as: :json

      expect(response).to have_attributes(
        code: "401",
        body: a_string_including("Access denied"),
      )
    end

    context "when the user is authorized" do
      let(:mock_api_token) { "mock-token" }
      let(:encrypted_mock_api_token) do
        ActionController::HttpAuthentication::Token.encode_credentials(mock_api_token)
      end

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:fetch).and_call_original

        allow(ENV).to receive(:[]).with("ONBOARDING_API_TOKEN").and_return(mock_api_token)
      end
      it "creates a hood and any houses" do
        expect {
          post onboard_path,
            params: request_body,
            headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token },
            as: :json
        }
          .to change { Hood.count }.from(0).to(1)
          .and change { House.count }.from(0).to(3)
      end

      it "returns a successful response" do
        post onboard_path,
          params: request_body,
          headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token },
          as: :json

        expect(response.code.to_i).to (be >= 200).and(be < 300)
      end
    end
  end
end
