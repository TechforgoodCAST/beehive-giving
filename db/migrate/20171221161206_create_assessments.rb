class CreateAssessments < ActiveRecord::Migration[5.1]
  def change
    create_table :assessments do |t|
      t.references :fund, foreign_key: true
      t.references :proposal, foreign_key: true
      t.references :recipient, foreign_key: true
      t.integer :eligibility_amount
      t.integer :eligibility_funding_type
      t.integer :eligibility_location
      t.integer :eligibility_org_income
      t.integer :eligibility_org_type
      t.integer :eligibility_quiz
      t.integer :eligibility_quiz_failing
    end
  end
end
