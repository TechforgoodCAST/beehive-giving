class AddVoteCountsToAssessment < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :agree_count, :integer, null: false, default: 0
    add_column :assessments, :disagree_count, :integer, null: false, default: 0
  end
end
