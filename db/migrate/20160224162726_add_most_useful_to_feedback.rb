class AddMostUsefulToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :most_useful, :string
  end
end
