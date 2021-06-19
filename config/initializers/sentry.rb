Sentry.init do |config|
  # if this environment variable is set, we don't need to have this file
  # however, we're leaving it here to allow us to customize any settings for Sentry in the future
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = Rails.env
end
