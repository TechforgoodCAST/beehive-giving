class RemoveGroupFromQuestions < ActiveRecord::Migration[5.1]
  def change
    remove_column :questions, :group, :string
  end
end
