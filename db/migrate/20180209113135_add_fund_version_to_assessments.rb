class AddFundVersionToAssessments < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :fund_version, :bigint
  end
end
