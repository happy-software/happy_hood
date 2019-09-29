class CreateHousePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :house_prices do |t|
      t.datetime :valuation_date
      t.string :source
      t.float :price
      t.jsonb :details

      t.timestamps
    end
  end
end
