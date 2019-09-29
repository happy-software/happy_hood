class CreateHomeOwnersAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :home_owners_associations do |t|
      t.boolean :active
      t.string :name
      t.string :email
      t.string :phone
      t.string :website

      t.timestamps
    end
    add_index :home_owners_associations, :active
  end
end
