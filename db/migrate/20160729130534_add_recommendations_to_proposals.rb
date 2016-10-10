class AddRecommendationsToProposals < ActiveRecord::Migration
  def change
    add_column :recommendations, :proposal_id, :integer
    add_column :recommendations, :fund_id, :integer
    add_column :recommendations, :fund_slug, :string
    add_index :recommendations, [:proposal_id, :fund_id], unique: true
    add_index :recommendations, [:proposal_id, :fund_slug], unique: true

    add_column :funds, :open_data, :boolean, null: true, default: false

    add_column :funds, :period_start, :date
    add_column :funds, :period_end, :date

    # Overview
    add_column :funds, :grant_count, :integer
    add_column :funds, :recipient_count, :integer

    add_column :funds, :amount_awarded_sum, :float
    add_column :funds, :amount_awarded_mean, :float
    add_column :funds, :amount_awarded_median, :float
    add_column :funds, :amount_awarded_min, :float
    add_column :funds, :amount_awarded_max, :float
    add_column :funds, :amount_awarded_distribution, :jsonb, null: false, default: {}

    add_column :funds, :duration_awarded_months_mean, :float
    add_column :funds, :duration_awarded_months_median, :float
    add_column :funds, :duration_awarded_months_min, :float
    add_column :funds, :duration_awarded_months_max, :float
    add_column :funds, :duration_awarded_months_distribution, :jsonb, null: false, default: {}
    add_column :funds, :award_month_distribution, :jsonb, null: false, default: {}

    # Recipient
    add_column :funds, :org_type_distribution, :jsonb, null: false, default: {}
    add_column :funds, :operating_for_distribution, :jsonb, null: false, default: {}
    add_column :funds, :income_distribution, :jsonb, null: false, default: {}
    add_column :funds, :employees_distribution, :jsonb, null: false, default: {}
    add_column :funds, :volunteers_distribution, :jsonb, null: false, default: {}

    # Beneficiary
    add_column :funds, :gender_distribution, :jsonb, null: false, default: {}
    add_column :funds, :age_group_distribution, :jsonb, null: false, default: {}
    add_column :funds, :beneficiary_distribution, :jsonb, null: false, default: {}

    # Location
    add_column :funds, :geographic_scale_distribution, :jsonb, null: false, default: {}
    add_column :funds, :country_distribution, :jsonb, null: false, default: {}
    add_column :funds, :district_distribution, :jsonb, null: false, default: {}
  end
end
