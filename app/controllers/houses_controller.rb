class HousesController < ApplicationController
  def valuations
    zpid = params[:zpid]
    house_details = HouseMetadatum.find_by_zpid(zpid)
    return render json: {data: "Could not find a house with zpid: #{zpid}"}, status: 404 unless house_details

    house = house_details.house
    render json: {data: house.price_history}, status: 200
  end
end