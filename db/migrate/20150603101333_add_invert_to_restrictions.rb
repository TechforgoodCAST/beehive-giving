class AddInvertToRestrictions < ActiveRecord::Migration
  def change
    add_column :restrictions, :invert, :boolean
  end
end
