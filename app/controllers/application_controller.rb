class ApplicationController < ActionController::Base
  private

  def authenticate_request(key)
    Rails.logger.info("Hello Hebron, an authentication request has come in for key: #{key}")
    is_match = ActiveSupport::SecurityUtils.secure_compare(token, key)
    Rails.logger.info("Hello Hebron, is_match =#{is_match}")
    authenticate_or_request_with_http_token do |token, _options|
      Rails.logger.info("Hello Hebron, their token is: #{token}")
      ActiveSupport::SecurityUtils.secure_compare(token, key)
    end
  end
end
