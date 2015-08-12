class AddPriorityToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :priority, :integer, default: 0
  end
end
