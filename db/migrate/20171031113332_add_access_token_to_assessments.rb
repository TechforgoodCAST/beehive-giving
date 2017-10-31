class AddAccessTokenToAssessments < ActiveRecord::Migration[5.1]
  def change
    add_column :assessments, :access_token, :string
  end
end
