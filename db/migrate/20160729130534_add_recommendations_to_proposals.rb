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
    add_column :funds, :grant_count, :integer
    add_column :funds, :recipient_count, :integer
    add_column :funds, :amount_mean_historic, :float
    add_column :funds, :amount_median_historic, :float
    add_column :funds, :amount_min_historic, :float
    add_column :funds, :amount_max_historic, :float
    add_column :funds, :duration_months_mean_historic, :float
    add_column :funds, :duration_months_median_historic, :float
    add_column :funds, :duration_months_min_historic, :float
    add_column :funds, :duration_months_max_historic, :float
    add_column :funds, :org_type_distribution, :json
    add_column :funds, :operating_for_distribution, :json
    add_column :funds, :income_distribution, :json
    add_column :funds, :employees_distribution, :json
    add_column :funds, :volunteers_distribution, :json
    add_column :funds, :geographic_scale_distribution, :json

    add_column :funds, :beneficiary_min_age_historic, :integer
    add_column :funds, :beneficiary_max_age_historic, :integer
    add_column :funds, :gender_distribution, :json
  end
end
