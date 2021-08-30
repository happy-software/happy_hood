class HousesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:import, :find_zpid]
  before_action { authenticate_request(ENV['HAPPY_HOUSE_API_TOKEN']) }

  def valuations
    return render json: {data: "Could not find a house with zpid: #{zpid}"}, status: 404 unless house_details

    render json: {data: house.price_history}, status: 200
  end

  def import
    return render json: {data: "Could not find a house with zpid: #{zpid}"}, status: 404 unless house_details
    return render json: {data: "Missing or improper valuation data"},        status: 400 unless valuations_param

    # This data write could be moved into it's own module or worker or something but whatever, getting it working for now
    price_history = house.price_history || {}
    valuations_param.each do |date, price|
      normalized_date = Date.parse(date).strftime("%Y-%m-%d")
      price_history[normalized_date] ||= price.to_f
    end
    house.price_history = price_history
    house.save!

    render json: {data: "Successfully imported valuation history!"}, status: 200
  end

  def find_zpid
    unless find_zpid_params.values.all? && find_zpid_params.keys.sort == [:street_address, :city, :state, :zip_code].sort
      return render json: {error: 'Missing one or more required params (street_address, city, state, zip_code)'}, status: 400
    end

    api_result = ZpidCollector.new(find_zpid_params).get_zpid
    unless api_result.success?
      return render json: {error: "Could not find a zpid for: #{find_zpid_params.dig(:street_address)}"}, status: 404
    end

    render json: {data: {zpid: api_result.zpid}}, status: 200
  end

  private

  def zpid
    params[:zpid]
  end

  def valuations_param
    return unless params[:valuations]
    JSON.parse params[:valuations]
  end

  def house_details
    @house_details ||= HouseMetadatum.find_by_zpid(zpid)
  end

  def house
    @house ||= house_details&.house
  end

  def find_zpid_params
    params.permit([:street_address, :city, :state, :zip_code])
          .slice(:street_address, :city, :state, :zip_code)
          .to_h.symbolize_keys
  end
end
