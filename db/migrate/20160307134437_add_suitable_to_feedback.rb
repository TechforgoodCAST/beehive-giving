class AddSuitableToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :suitable, :integer
  end
end
