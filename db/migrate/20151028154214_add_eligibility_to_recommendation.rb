class AddEligibilityToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :eligibility, :string
  end
end
