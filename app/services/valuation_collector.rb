class ValuationCollector
  def initialize(house)
    @house = house
  end

  def perform
    raise ValuationCollectorError.new("House(id: #{@house.id}) does not have a zpid.") if @house.zpid.nil?

    property = Rubillow::HomeValuation.zestimate({ zpid: @house.zpid })

    if property.success?
      @house
        .add_valuation(Date.today, property.price)
        .save!
    else
      raise ValuationCollectorError.new(<<~ERR.strip)
        Could not update House(id: #{@house.id}). #{property.message}
      ERR
    end
  end
end

class ValuationCollectorError < StandardError; end
