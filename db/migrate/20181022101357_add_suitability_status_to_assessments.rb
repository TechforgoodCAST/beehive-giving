class AddSuitabilityStatusToAssessments < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :suitability_status, :string
  end
end
