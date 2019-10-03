class AddSquareFeetToHouseMetadatum < ActiveRecord::Migration[5.2]
  def change
    add_column :house_metadata, :square_feet, :float
  end
end
