class UpdateHouseMetadataTypes < ActiveRecord::Migration[5.2]
  def change
    change_column :house_metadata, :bedrooms, :float
    change_column :house_metadata, :bathrooms, :float
    change_column :house_metadata, :garage_count, :float
  end
end
