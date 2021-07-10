Sentry.init do |config|
  # if this environment variable is set, we don't need to have this file
  # however, we're leaving it here to allow us to customize any settings for Sentry in the future
  config.dsn = Configuration::Sentry.dsn
  config.environment = Configuration::Sentry.environment
end
