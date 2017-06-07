class AddRecommendationToProposal < ActiveRecord::Migration[5.0]
  def change
    remove_column :proposals, :eligible_funds
    remove_column :proposals, :ineligible_funds
    add_column :proposals, :recommendation, :jsonb, default: {}, null: false
  end
end
