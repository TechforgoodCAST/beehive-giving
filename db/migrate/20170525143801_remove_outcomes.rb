class RemoveOutcomes < ActiveRecord::Migration[5.0]
  def change
    drop_table :outcomes
    drop_table :funds_outcomes

    remove_column :funds, :outcomes_known
  end
end
