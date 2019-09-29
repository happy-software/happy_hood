class CreateHoods < ActiveRecord::Migration[5.2]
  def change
    create_table :hoods do |t|
      t.string :name
      t.string :zip_code

      t.timestamps
    end
    add_index :hoods, :zip_code
  end
end
