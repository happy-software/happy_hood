class DropHousePrice < ActiveRecord::Migration[5.2]
  def change
    drop_table :house_prices
  end
end
