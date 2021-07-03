class OnboardingController < ApplicationController
  def hood_and_houses
    permitted_params = params.permit(entries: Hood::Onboarder::RequiredFields)

    entries = permitted_params.to_h[:entries]

    Hood::Onboarder.run(entries)
  end
end
