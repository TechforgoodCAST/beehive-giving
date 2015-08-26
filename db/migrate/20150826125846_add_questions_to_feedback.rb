class AddQuestionsToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :application_frequency, :string, required: true
    add_column :feedbacks, :grant_frequency, :string, required: true
    add_column :feedbacks, :marketing_frequency, :string, required: true
  end
end
