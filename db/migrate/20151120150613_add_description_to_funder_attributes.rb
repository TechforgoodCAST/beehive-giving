class AddDescriptionToFunderAttributes < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :description, :text
  end
end
