class RemoveNumcodeFromCountry < ActiveRecord::Migration
  def change
    remove_column :countries, :numcode, :integer
    remove_column :countries, :iso3, :string
    rename_column :countries, :iso2, :alpha2
    rename_column :districts, :iso, :subdivision
  end
end
