class RemoveConditionFromRestrictions < ActiveRecord::Migration[5.1]
  def change
    remove_column :restrictions, :has_condition, :boolean
    remove_column :restrictions, :condition, :string
  end
end
