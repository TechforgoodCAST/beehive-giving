class RenameAssessmentsFundingType < ActiveRecord::Migration[5.1]
  def change
    rename_column :assessments, :eligibility_funding_type, :eligibility_proposal_categories
  end
end
