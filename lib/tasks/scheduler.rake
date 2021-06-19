require 'happy_hood/slack/client'

desc 'Collect Zillow Zestimate for each House'
task house_valuation_collector: :environment do
  House.find_each do |house|
    begin
      ValuationCollector.new(house).perform
    rescue ValuationCollectorError => e
      # report but do not stop from doing this for other properties
      # TODO implement Sentry alerting
      Rails.logger.error e
    end
  end

  HappyHood::Slack::Client.send_daily_price_summary
end

desc 'Ping Zillow to get property zpid'
task collect_zpids: :environment do
  Rails.logger.info { "Gathering zpids for houses with no zpids" }

  result = ZpidCollector.fill_missing_zpids

  Rails.logger.info { "Updated #{result.updated_count} out of #{result.total_houses} without zpids." }
end

desc "Send monthly summary to Slack"
task monthly_price_summary: :environment do
  HappyHood::Slack::Client.send_monthly_price_summary
end
