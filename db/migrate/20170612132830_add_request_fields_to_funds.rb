class AddRequestFieldsToFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :funds, :min_amount_awarded_limited, :boolean, default: false
    add_column :funds, :min_amount_awarded, :integer
    add_column :funds, :max_amount_awarded_limited, :boolean, default: false
    add_column :funds, :max_amount_awarded, :integer
    add_column :funds, :min_duration_awarded_limited, :boolean, default: false
    add_column :funds, :min_duration_awarded, :integer
    add_column :funds, :max_duration_awarded_limited, :boolean, default: false
    add_column :funds, :max_duration_awarded, :integer
    add_column :funds, :permitted_costs, :jsonb, null: false, default: []
  end
end
