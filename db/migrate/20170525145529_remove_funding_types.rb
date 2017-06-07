class RemoveFundingTypes < ActiveRecord::Migration[5.0]
  def change
    drop_table :funding_types
    drop_table :funding_types_funds
  end
end
