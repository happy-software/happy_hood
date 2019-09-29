class CreateHouses < ActiveRecord::Migration[5.2]
  def change
    create_table :houses do |t|
      t.jsonb :address
      t.references :hood, index: true, foreign_key: true

      t.timestamps
    end
  end
end
