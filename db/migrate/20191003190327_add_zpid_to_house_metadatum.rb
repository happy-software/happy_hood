class AddZpidToHouseMetadatum < ActiveRecord::Migration[5.2]
  def change
    add_column :house_metadata, :zpid, :string, index: true
    add_reference :house_metadata, :house, foreign_key: true, index: true
  end
end
