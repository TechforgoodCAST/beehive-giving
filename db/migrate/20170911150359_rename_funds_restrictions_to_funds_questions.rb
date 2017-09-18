class RenameFundsRestrictionsToFundsQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_table :funds_restrictions, :funds_questions
    rename_column :funds_questions, :restriction_id, :question_id
  end
end
