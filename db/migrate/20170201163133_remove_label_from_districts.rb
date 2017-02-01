class RemoveLabelFromDistricts < ActiveRecord::Migration[5.0]
  def change
    remove_column :districts, :label, :string
  end
end
