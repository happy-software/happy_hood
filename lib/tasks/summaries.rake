require "happy_hood/slack/client"

namespace :summaries do
  desc "Send daily summary to Slack"
  task daily: :environment do
    cache_key = "daily_summary/#{Date.today}"
    sent_message = false

    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      HappyHood::Slack::Client.send_daily_price_summary

      sent_message = true
    end

    Rails.logger.info do
      if sent_message
        "Sent summary for cache key: #{cache_key}"
      else
        "Already sent summary. Skipping. Cache key: #{cache_key}"
      end
    end
  end

  desc "Send monthly summary to Slack"
  task monthly: :environment do
    cache_key = "monthly_summary/#{Date.today.beginning_of_month}"
    sent_message = false

    Rails.cache.fetch(cache_key, expires_in: 1.month) do
      HappyHood::Slack::Client.send_monthly_price_summary

      sent_message = true
    end

    Rails.logger.info do
      if sent_message
        "Sent monthly summary for cache key: #{cache_key}"
      else
        "Already sent monthly summary. Skipping. Cache key: #{cache_key}"
      end
    end
  end
end
