class AddOrgTypeToFund < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :permitted_org_types, :jsonb, null: false, default: []
  end
end
