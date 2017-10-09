class RenameFundsQuestionsToQuestion < ActiveRecord::Migration[5.1]
  def change
    rename_table :funds_questions, :questions
    add_column :questions, :criterion_type, :string, default: 'Restriction'
    add_column :questions, :group, :string

    reversible do |dir|
      dir.up do
        Question.all.each do |q|
          q.update(criterion_type: Criterion.find(q.criterion_id).type)
        end
      end
    end
  end
end
