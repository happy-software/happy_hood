desc 'Collect Zillow Zestimate for each House'
task :house_valuation_collector => :environment do
  House.all.each do |house|
    next unless zpid = house.house_metadatum.zpid

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
end
