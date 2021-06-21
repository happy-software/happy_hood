class ZpidCollector
  def self.fill_missing_zpids
    total_houses = 0
    updated_count = 0

    House.includes(:house_metadatum).where(house_metadatum: { zpid: nil }).find_each do |house|
      begin
        new(house).get_zpid
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

  def initialize(house)
    @house = house
  end

  def get_zpid
    property = Rubillow::HomeValuation.search_results(
      address: @house.street_address,
      citystatezip: "#{@house.city}, #{@house.state} #{@house.zip_code}",
    )

    if property.success?
      @house.house_metadatum.update(zpid: property.zpid)

      Rails.logger.info { "Added zpid for House(id: #{@house.id})" }
    else
      raise ZpidCollectorError.new("Could not update zpid for House(id: #{@house.id}): #{property.message}")
    end
  end
end

class ZpidCollectorError < StandardError; end

ZpidCollectorResult = Struct.new(:updated_count, :total_houses, keyword_init: true)
