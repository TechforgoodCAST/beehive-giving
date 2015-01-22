class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      t.string :name, size: 100
      t.string :iso2, size: 2
      t.string :iso3, size: 3
      t.integer :numcode
    end

    Country.create(:name => 'United Kingdom', :iso3 => 'GBR', :iso2 => 'GB', :numcode => 826)
    Country.create(:name => 'Ethiopia', :iso3 => 'ETH', :iso2 => 'ET', :numcode => 231)
    Country.create(:name => 'Kenya', :iso3 => 'KEN', :iso2 => 'KE', :numcode => 404)
    Country.create(:name => 'Uganda', :iso3 => 'UGA', :iso2 => 'UG', :numcode => 800)

    create_table :countries_profiles do |t|
      t.references :country
      t.references :profile
    end

    create_table :districts do |t|
      t.references :country
      t.string :label, :district
      t.string :iso
    end

    create_table :districts_profiles do |t|
      t.references :district
      t.references :profile
    end
  end

  def down
    drop_table :countries
    drop_table :countries_profiles
    drop_table :districts
    drop_table :districts_profiles
  end
end
