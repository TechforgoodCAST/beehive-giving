class AddSourcesToFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :sources, :jsonb, null: false, default: {}
  end
end
