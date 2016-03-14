class AddOperatingForToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :operating_for, :integer
  end
end
