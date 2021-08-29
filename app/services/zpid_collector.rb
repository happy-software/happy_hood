require 'rubillow'

class ZpidCollector
  def self.fill_missing_zpids
    total_houses = 0
    updated_count = 0

    House.includes(:house_metadatum).where(house_metadatum: { zpid: nil }).find_each do |house|
      begin
        search_details = {
          street_address: house.street_address,
          city:           house.city,
          state:          house.state,
          zip_code:       house.zip_code
        }
        api_result = new(search_details).get_zpid

        if api_result.success?
          house.house_metadatum.update(zpid: api_result.zpid)

          Rails.logger.info { "Added zpid for House(id: #{house.id})" }
        else
          raise ZpidCollectorError.new("Could not update zpid for House(id: #{house.id}): #{api_result.message}")
        end

        updated_count += 1
      rescue ZpidCollectorError => e
        Rails.logger.error e
        Sentry.capture_exception(e, extra: { house_id: house.id })
      ensure
        total_houses += 1
      end
    end

    ZpidCollectorResult.new(updated_count: updated_count, total_houses: total_houses)
  end

  def initialize(street_address:, city:, state:, zip_code:)
    @street_address = street_address
    @city           = city
    @state          = state
    @zip_code       = zip_code
  end

  def get_zpid
    Rubillow::HomeValuation.search_results(
      address: @street_address,
      citystatezip: "#{@city}, #{@state} #{@zip_code}",
    )
  end
end

class ZpidCollectorError < StandardError; end

ZpidCollectorResult = Struct.new(:updated_count, :total_houses, keyword_init: true)
