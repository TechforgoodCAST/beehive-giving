class RenameEligibilityToAnswers < ActiveRecord::Migration[5.1]
  def change
    rename_table :eligibilities, :answers
    rename_column :answers, :restriction_id, :question_id
  end
end
