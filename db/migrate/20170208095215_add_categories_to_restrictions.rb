class AddCategoriesToRestrictions < ActiveRecord::Migration[5.0]
  def change
    add_column :restrictions, :category, :string, default: 'Proposal', null: false
    add_column :restrictions, :has_condition, :boolean, default: false, null: false
    add_column :restrictions, :condition, :string
    change_column :restrictions, :details, :string, null: false
    change_column :restrictions, :invert, :boolean, default: false, null: false
  end
end
