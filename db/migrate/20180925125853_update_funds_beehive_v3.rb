class UpdateFundsBeehiveV3 < ActiveRecord::Migration[5.1]
  def change
    remove_column :funds, :open_call, :boolean
    remove_column :funds, :key_criteria, :text
    remove_column :funds, :currency, :string
    remove_column :funds, :restrictions_known, :boolean
    remove_column :funds, :priorities_known, :boolean
    remove_column :funds, :open_data, :boolean
    remove_column :funds, :period_start, :date
    remove_column :funds, :period_end, :date
    remove_column :funds, :grant_count, :integer
    remove_column :funds, :amount_awarded_distribution, :jsonb
    remove_column :funds, :award_month_distribution, :jsonb
    remove_column :funds, :org_type_distribution, :jsonb
    remove_column :funds, :income_distribution, :jsonb
    remove_column :funds, :country_distribution, :jsonb
    remove_column :funds, :tags, :jsonb
    remove_column :funds, :amount_awarded_sum, :decimal
    remove_column :funds, :beneficiary_distribution, :jsonb
    remove_column :funds, :grant_examples, :jsonb
    remove_column :funds, :min_amount_awarded_limited, :boolean
    remove_column :funds, :max_amount_awarded_limited, :boolean
    remove_column :funds, :min_duration_awarded_limited, :boolean
    remove_column :funds, :max_duration_awarded_limited, :boolean
    remove_column :funds, :min_org_income_limited, :boolean
    remove_column :funds, :max_org_income_limited, :boolean
    remove_column :funds, :geo_description, :string
    remove_column :funds, :featured, :boolean
    remove_column :funds, :pretty_name, :string

    rename_column :funds, :application_link, :website
    rename_column :funds, :geographic_scale_limited, :proposal_area_limited
    rename_column :funds, :sources, :links
    rename_column :funds, :min_amount_awarded, :proposal_min_amount
    rename_column :funds, :max_amount_awarded, :proposal_max_amount
    rename_column :funds, :min_duration_awarded, :proposal_min_duration
    rename_column :funds, :max_duration_awarded, :proposal_max_duration
    rename_column :funds, :permitted_costs, :proposal_categories
    rename_column :funds, :permitted_org_types, :recipient_categories
    rename_column :funds, :min_org_income, :recipient_min_income
    rename_column :funds, :max_org_income, :recipient_max_income

    add_index :funds, :geo_area_id

    add_column :funds, :proposal_permitted_geographic_scales, :jsonb, default: [], null: false
    add_column :funds, :proposal_all_in_area, :boolean
  end
end
