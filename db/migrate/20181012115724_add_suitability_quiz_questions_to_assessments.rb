class AddSuitabilityQuizQuestionsToAssessments < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :suitability_quiz, :integer
    add_column :assessments, :suitability_quiz_failing, :integer
  end
end
