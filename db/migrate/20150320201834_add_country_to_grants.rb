class AddCountryToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :country, :string
  end
end
