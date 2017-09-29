class RenameFundsQuestionCriterion < ActiveRecord::Migration[5.1]
  def change
    rename_column :funds_questions, :question_id, :criterion_id
    rename_column :answers, :question_id, :criterion_id
  end
end
