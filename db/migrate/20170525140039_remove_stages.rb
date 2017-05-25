class RemoveStages < ActiveRecord::Migration[5.0]
  def change
    drop_table :stages

    remove_column :funds, :stages_known
    remove_column :funds, :stages_count
  end
end
