class ApplicationController < ActionController::Base
  private

  def authenticate(key)
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(token, key)
    end
  end
end
