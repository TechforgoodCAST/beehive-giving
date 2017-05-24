class RemoveGeographicScaleAndAddNationalToFunds < ActiveRecord::Migration[5.0]
  def change
    remove_column :funds, :geographic_scale, :integer, required: true
    add_column :funds, :national, :boolean, null: false, default: false
  end
end
