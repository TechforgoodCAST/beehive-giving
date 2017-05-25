class RemoveDecisionMakers < ActiveRecord::Migration[5.0]
  def change
    drop_table :decision_makers
    drop_table :decision_makers_funds

    remove_column :funds, :decision_makers_known
  end
end
