require 'happy_hood/slack/client'

desc 'Collect Zillow Zestimate for each House'
task :house_valuation_collector => :environment do
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
task :collect_zpids => :environment do
  missing_zpids = ::HouseMetadatum.where(zpid: nil)
  puts "Looking over #{missing_zpids.count} missing Zillow ids"
  missing_zpids.each do |metadata|
    house = metadata.house
    address = house.address
    street_address = house.address['street_address']
    citystatezip = "#{address['city']}, #{address['state']} #{address['zip_code']}"
    # require 'pry'; binding.pry
    property = Rubillow::HomeValuation.search_results(address: street_address, citystatezip: citystatezip)
    puts "Property address: #{street_address}\nProperty citystatezip: #{citystatezip}"
    ((property.success?) && (zpid = property.zpid)) ? metadata.zpid = zpid : metadata.zpid = nil
    puts "API Call was #{property.success? ? 'successful' : "unsuccessful: #{property.message}"}"
    metadata.save!
    house.save!
  end

  puts "Missing ZPIDs for #{missing_zpids.reload.where(zpid: nil).count}"
end

desc "Send monthly summary to Slack"
task monthly_price_summary: :environment do
  HappyHood::Slack::Client.send_monthly_price_summary
end
