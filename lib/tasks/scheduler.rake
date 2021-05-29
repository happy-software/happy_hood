require 'happy_hood/slack/client'

desc 'Collect Zillow Zestimate for each House'
task :house_valuation_collector => :environment do
  House.find_each do |house|
    next unless zpid = house&.house_metadatum&.zpid

    property = Rubillow::HomeValuation.zestimate({ :zpid => zpid })

    if property.success?
      price_history = house.price_history || {}
      normalized_valuation_date = Date.current.strftime("%Y-%m-%d")
      price_history[normalized_valuation_date] ||= property.price.to_f
      house.price_history = price_history
      house.save!
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

NeighborhoodCsvHeaders = %w(
  neighborhood_name
  neighborhood_zip_code
  house_street_address
  house_city
  house_state
  house_zip_code
  house_bedrooms
  house_bathrooms
  house_square_feet
).freeze

desc "Generate a csv to onboard a neighborhood"
task generate_hood_onboarding_csv: :environment do |t|
  require "csv"

  filename = "#{DateTime.now.to_i}_onboard_neighborhood.csv"
  CSV.open(filename, "w") { |csv| csv << NeighborhoodCsvHeaders }

  Rails.logger.info "Created #{filename}"
end

desc 'Upload a CSV of a neighborhood'
task :upload_neighborhood, [:hood_onboarding_csv_path] => :environment do |t, args|
  starting_count = House.count

  csv_entries = CSV.read(args[:hood_onboarding_csv_path], headers: true).map(&:to_h)

  if csv_entries.flat_map(&:keys).uniq != NeighborhoodCsvHeaders
    error = <<~ERR
      #{args[:hood_onboarding_csv_path]} does not have valid headers.
      Got: #{csv_entries.flat_map(&:keys).uniq}
      Want: #{NeighborhoodCsvHeaders}
    ERR

    raise ArgumentError, error
  end

  csv_entries.each do |csv_entry|
    hood = Hood.find_or_create_by(name: csv_entry["neighborhood_name"], zip_code: csv_entry["neighborhood_zip_code"])

    street_address = csv_entry["house_street_address"]&.strip
    city           = csv_entry["house_city"]&.strip
    state          = csv_entry["house_state"]&.strip
    zip_code       = csv_entry["house_zip_code"]&.strip
    bedrooms       = csv_entry["house_bedrooms"]&.strip
    bathrooms      = csv_entry["house_bathrooms"]&.strip
    square_feet    = csv_entry["house_square_feet"]&.strip

    if street_address && city && state && zip_code
      house = hood.houses.create(address: {
        street_address: street_address,
        city: city,
        state: state,
        zip_code: zip_code
      })

      HouseMetadatum.create(bedrooms: bedrooms, bathrooms: bathrooms, square_feet: square_feet, house: house)
    end
  end

  ending_count = House.count
  Rails.logger.info <<~MSG.strip
    There are #{ending_count} houses in the database now (#{ending_count-starting_count} added)
  MSG
end

