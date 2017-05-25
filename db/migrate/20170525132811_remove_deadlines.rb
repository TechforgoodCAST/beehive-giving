class RemoveDeadlines < ActiveRecord::Migration[5.0]
  def change
    drop_table :deadlines

    remove_column :funds, :deadlines_known
    remove_column :funds, :deadlines_limited
  end
end
