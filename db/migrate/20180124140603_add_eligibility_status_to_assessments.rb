class AddEligibilityStatusToAssessments < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :eligibility_status, :integer, null: false
  end
end
