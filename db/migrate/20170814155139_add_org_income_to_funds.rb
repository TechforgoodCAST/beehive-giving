class AddOrgIncomeToFunds < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :min_org_income_limited, :boolean, default: false
    add_column :funds, :min_org_income, :integer
    add_column :funds, :max_org_income_limited, :boolean, default: false
    add_column :funds, :max_org_income, :integer
    rename_column :organisations, :income, :income_band
    add_column :organisations, :income, :integer
  end
end
