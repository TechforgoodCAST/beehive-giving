class AddRegionsAndSubCountriesToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :region, :string
    add_column :districts, :sub_country, :string
  end
end
