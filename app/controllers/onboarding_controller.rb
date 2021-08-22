class OnboardingController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action { authenticate(ENV['ONBOARDING_API_TOKEN']) }

  def hood_and_houses
    permitted_params = params.permit(entries: Hood::Onboarder::RequiredFields)

    entries = permitted_params.to_h[:entries]

    Hood::Onboarder.run(entries)
  end
end
