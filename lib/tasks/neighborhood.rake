namespace :neighborhood do
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
  task generate_onboarding_csv: :environment do |t|
    require "csv"

    filename = "#{DateTime.now.to_i}_onboard_neighborhood.csv"
    CSV.open(filename, "w") { |csv| csv << NeighborhoodCsvHeaders }

    Rails.logger.info "Created #{filename}"
  end

  desc 'Upload a CSV of a neighborhood'
  task :upload, [:onboarding_csv_path] => :environment do |t, args|
    starting_count = House.count

    csv_entries = CSV.read(args[:onboarding_csv_path], headers: true).map(&:to_h)

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
end
