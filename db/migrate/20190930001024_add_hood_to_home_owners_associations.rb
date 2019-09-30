class AddHoodToHomeOwnersAssociations < ActiveRecord::Migration[5.2]
  def change
    add_reference :home_owners_associations, :hood, foreign_key: true
  end
end
