class RemoveCriteriaIDsFromFund < ActiveRecord::Migration[5.1]
  def change
    remove_column :funds, :priority_ids, :jsonb
    remove_column :funds, :restriction_ids, :jsonb
  end
end
