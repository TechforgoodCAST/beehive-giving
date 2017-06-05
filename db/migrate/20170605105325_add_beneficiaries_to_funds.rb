class AddBeneficiariesToFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :beneficiary_distribution, :jsonb, null: false, default: {}
  end
end
