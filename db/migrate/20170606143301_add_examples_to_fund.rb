class AddExamplesToFund < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :grant_examples, :jsonb, null: false, default: []
  end
end
