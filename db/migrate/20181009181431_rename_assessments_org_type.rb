class RenameAssessmentsOrgType < ActiveRecord::Migration[5.1]
  def change
    rename_column :assessments, :eligibility_org_type, :eligibility_recipient_categories
  end
end
