class AddPriceHistoryToHouse < ActiveRecord::Migration[5.2]
  def change
    add_column :houses, :price_history, :jsonb
  end
end
