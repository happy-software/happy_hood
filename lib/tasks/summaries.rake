require "happy_hood/slack/client"

namespace :summaries do
  desc "Send daily summary to Slack"
  task daily: :environment do
    cache_key = "daily_summary/#{Date.today}"
    sent_message = false

    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      HappyHood::Slack::Client.send_summary_using_blocks(
        summary_type: :daily,
        start_date: 1.day.ago,
        end_date: Date.today,
        error_text: "No changes for any HappyHood",
      )

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
      HappyHood::Slack::Client.send_summary_using_blocks(
        summary_type: :monthly,
        start_date: Date.today.beginning_of_month,
        end_date: Date.today,
      )

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

  desc "Send quarterly summary to Slack"
  task quarterly: :environment do
    beginning_of_quarter = (Date.today - 1.day).beginning_of_quarter # start of last quarter
    end_of_quarter = (Date.today - 1.day).end_of_quarter # end of last quarter

    cache_key = "quarterly_summary/#{end_of_quarter}"
    expires_in = (end_of_quarter - beginning_of_quarter).to_i.days

    sent_message = false

    Rails.cache.fetch(cache_key, expires_in: expires_in) do
      HappyHood::Slack::Client.send_summary_using_blocks(
        summary_type: :quarterly,
        start_date: beginning_of_quarter,
        end_date: end_of_quarter,
      )

      sent_message = true
    end

    Rails.logger.info do
      if sent_message
        "Sent quarterly summary for cache key: #{cache_key}"
      else
        "Already sent quarterly summary. Skipping. Cache key: #{cache_key}"
      end
    end
  end
end
