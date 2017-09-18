class RenameRestrictionsToQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_table :restrictions, :questions
    add_column :questions, :type, :string, default: 'Restriction'
  end
end
