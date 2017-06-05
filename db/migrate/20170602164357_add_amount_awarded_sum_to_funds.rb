class AddAmountAwardedSumToFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :amount_awarded_sum, :decimal
  end
end
