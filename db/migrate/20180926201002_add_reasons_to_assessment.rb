class AddReasonsToAssessment < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :reasons, :jsonb, default: {}, null: false
  end
end
