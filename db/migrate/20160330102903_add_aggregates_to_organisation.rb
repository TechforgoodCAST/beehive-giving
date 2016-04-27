class AddAggregatesToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :income, :integer
    add_column :organisations, :employees, :integer
    add_column :organisations, :volunteers, :integer

    drop_table :recipient_attributes
  end
end
