class AddEligibilityCountsToProposal < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :recommended_funds, :jsonb, default: []
    add_column :proposals, :eligible_funds, :jsonb, default: []
    add_column :proposals, :ineligible_funds, :jsonb, default: []
  end
end
