class CreateHouseMetadata < ActiveRecord::Migration[5.2]
  def change
    create_table :house_metadata do |t|
      t.integer :garage_count
      t.integer :bedrooms
      t.integer :bathrooms

      t.timestamps
    end
  end
end
