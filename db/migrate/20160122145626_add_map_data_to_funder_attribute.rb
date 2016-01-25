class AddMapDataToFunderAttribute < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :map_data, :text
  end
end
