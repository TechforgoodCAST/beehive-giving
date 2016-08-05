class AddRecommendationsToProposals < ActiveRecord::Migration
  def change
    add_column :recommendations, :fund_id, :integer
    add_index :recommendations, :fund_id, unique: true
    add_column :recommendations, :fund_slug, :integer
    add_index :recommendations, :fund_slug, unique: true
    add_column :recommendations, :proposal_id, :integer
    add_index :recommendations, :proposal_id, unique: true
  end
end
