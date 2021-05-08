require 'happy_hood/slack/client'

desc 'Collect Zillow Zestimate for each House'
task :house_valuation_collector => :environment do
  House.find_each do |house|
    next unless zpid = house&.house_metadatum&.zpid

    property = Rubillow::HomeValuation.zestimate({ :zpid => zpid })
    if property.success?
      p = house.house_prices.new
      p.valuation_date = Date.current
      p.source = 'zillow'
      p.price = property.price
      p.details = property.as_json
      p.save!
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

desc 'Upload a CSV of a neighborhood'
task :upload_neighborhood, [:neighborhood_name, :neighborhood_zip_code, :neighborhood_data] => :environment do |t, args|
  starting_count = House.count
  puts "There are #{starting_count} houses in the database."
  puts "You have passed in #{args.count} arguments, with these keys: #{args.keys}"
  hood = Hood.find_or_create_by(name: args[:neighborhood_name], zip_code: args[:neighborhood_zip_code])

  args[:neighborhood_data].each do |row|
    street_address = row[0]&.strip
    city           = row[1]&.strip
    state          = row[2]&.strip
    zip_code       = row[3]&.strip
    bedrooms       = row[4]&.strip
    bathrooms      = row[5]&.strip
    square_feet    = row[6]&.strip

    address = {street_address: street_address, city: city, state: state, zip_code: zip_code}
    h = House.create(address: address, hood: hood)
    HouseMetadatum.create(bedrooms: bedrooms, bathrooms: bathrooms, square_feet: square_feet, house: h)
  end

  ending_count = House.count
  puts "There are #{ending_count} houses in the database now. That's #{ending_count-starting_count} more"
end

