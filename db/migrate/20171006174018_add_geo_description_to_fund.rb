class AddGeoDescriptionToFund < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :geo_description, :string
  end
end
