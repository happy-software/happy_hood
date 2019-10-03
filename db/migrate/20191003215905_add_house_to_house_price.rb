class AddHouseToHousePrice < ActiveRecord::Migration[5.2]
  def change
    add_reference :house_prices, :house, foreign_key: true
  end
end
