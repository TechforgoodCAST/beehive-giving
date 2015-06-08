class AddYearToFunderAttributes < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :year, :integer
  end
end
