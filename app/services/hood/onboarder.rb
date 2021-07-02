class Hood
  class Onboarder
    RequiredHeaders = %i(
      hood_name
      hood_zip_code
      house_street_address
      house_city
      house_state
      house_zip_code
      house_bedrooms
      house_bathrooms
      house_square_feet
    ).freeze

    def self.run(csv_entries)
      csv_entries.each do |entry|
        new(entry).perform
      end
    end

    def initialize(csv_entry)
      @neighborhood_name = csv_entry[:hood_name]&.strip
      @neighborhood_zip_code = csv_entry[:hood_zip_code]&.strip
      @house_street_address = csv_entry[:house_street_address]&.strip
      @house_city = csv_entry[:house_city]&.strip
      @house_state = csv_entry[:house_state]&.strip
      @house_zip_code = csv_entry[:house_zip_code]&.strip
      @house_bedrooms = csv_entry[:house_bedrooms]&.strip
      @house_bathrooms = csv_entry[:house_bathrooms]&.strip
      @house_square_feet = csv_entry[:house_square_feet]&.strip
    end

    def perform
      hood = Hood.find_or_create_by(
        name: @neighborhood_name,
        zip_code: @neighborhood_zip_code,
      )

      if @house_street_address && @house_city && @house_zip_code
        metadatum = HouseMetadatum.new(
          bedrooms: @house_bedrooms,
          bathrooms: @house_bathrooms,
          square_feet: @house_square_feet,
        )

        hood.houses.create(
          house_metadatum: metadatum,
          address: {
            street_address: @house_street_address,
            city: @house_city,
            state: @house_state,
            zip_code: @house_zip_code,
          },
        )
      end
    end
  end
end
