class OnboardingController < ApplicationController
  before_action :authenticate

  def hood_and_houses
    permitted_params = params.permit(entries: Hood::Onboarder::RequiredFields)

    entries = permitted_params.to_h[:entries]

    Hood::Onboarder.run(entries)
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, ENV["ONBOARDING_API_TOKEN"])
    end
  end
end
