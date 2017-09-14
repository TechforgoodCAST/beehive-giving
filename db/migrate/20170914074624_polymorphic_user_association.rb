class PolymorphicUserAssociation < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :role, :organisation_type
    change_column_default :users, :organisation_type, from: 'User', to: 'Recipient'
    add_index :users, :organisation_type
  end
end
