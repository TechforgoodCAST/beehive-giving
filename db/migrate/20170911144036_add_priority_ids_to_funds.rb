class AddPriorityIdsToFunds < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :priority_ids, :jsonb
  end
end
