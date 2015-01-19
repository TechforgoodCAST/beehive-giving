class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      t.string :name, size: 100
      t.string :iso2, size: 2
      t.string :iso3, size: 3
      t.integer :numcode
    end

    Country.create(:name => 'Ethiopia', :iso3 => 'ETH', :iso2 => 'ET', :numcode => 231)
    Country.create(:name => 'Kenya', :iso3 => 'KEN', :iso2 => 'KE', :numcode => 404)
    Country.create(:name => 'Uganda', :iso3 => 'UGA', :iso2 => 'UG', :numcode => 800)
    Country.create(:name => 'United Kingdom', :iso3 => 'GBR', :iso2 => 'GB', :numcode => 826)

    create_table :countries_profiles do |t|
      t.references :country
      t.references :profile
    end

    create_table :districts do |t|
      t.references :country
      t.string :label, :district
      t.string :iso
    end

    District.create(country_id: 1, label: 'Ethiopia - Addis Ababa', district: 'Addis Ababa', iso: 'ET-AA')
    District.create(country_id: 1, label: 'Ethiopia - Dire Dawa', district: 'Dire Dawa', iso: 'ET-DD')
    District.create(country_id: 1, label: 'Ethiopia - Afar', district: 'Afar', iso: 'ET-AF')
    District.create(country_id: 1, label: 'Ethiopia - Amara', district: 'Amara', iso: 'ET-AM')
    District.create(country_id: 1, label: 'Ethiopia - Benshangul-Gumaz', district: 'Benshangul-Gumaz', iso: 'ET-BE')
    District.create(country_id: 1, label: 'Ethiopia - Gambela Peoples', district: 'Gambela Peoples', iso: 'ET-GA')
    District.create(country_id: 1, label: 'Ethiopia - Harari People', district: 'Harari People', iso: 'ET-HA')
    District.create(country_id: 1, label: 'Ethiopia - Oromia', district: 'Oromia', iso: 'ET-OR')
    District.create(country_id: 1, label: 'Ethiopia - Somali', district: 'Somali', iso: 'ET-SO')
    District.create(country_id: 1, label: 'Ethiopia - Tigrai', district: 'Tigrai', iso: 'ET-TI')
    District.create(country_id: 1, label: 'Ethiopia - Southern Nations, Nationalities and Peoples', district: 'Southern Nations, Nationalities and Peoples', iso: 'ET-SN')

    District.create(country_id: 2, label: 'Kenya - Nairobi', district: 'Nairobi', iso: 'KE-110')
    District.create(country_id: 2, label: 'Kenya - Central', district: 'Central', iso: 'KE-200')
    District.create(country_id: 2, label: 'Kenya - Coast', district: 'Coast', iso: 'KE-300')
    District.create(country_id: 2, label: 'Kenya - Eastern', district: 'Eastern', iso: 'KE-400')
    District.create(country_id: 2, label: 'Kenya - North-Eastern', district: 'North-Eastern', iso: 'KE-500')
    District.create(country_id: 2, label: 'Kenya - Nyanza', district: 'Nyanza', iso: 'KE-600')
    District.create(country_id: 2, label: 'Kenya - Rift Valley', district: 'Rift Valley', iso: 'KE-700')
    District.create(country_id: 2, label: 'Kenya - Western', district: 'Western', iso: 'KE-800')

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
