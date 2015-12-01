class AddGeometryToDistrict < ActiveRecord::Migration
  def change
    add_column :districts, :geometry, :text
  end
end
