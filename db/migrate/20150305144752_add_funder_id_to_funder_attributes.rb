class AddFunderIdToFunderAttributes < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :funder_id, :integer
  end
end
