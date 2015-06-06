class AddCountriesAndDistrictsToGrants < ActiveRecord::Migration
  def change
    remove_column :grants, :country, :string

    create_table :countries_grants do |t|
      t.references :country
      t.references :grant

      t.timestamps null: false
    end

    create_table :districts_grants do |t|
      t.references :district
      t.references :grant

      t.timestamps null: false
    end
  end
end
