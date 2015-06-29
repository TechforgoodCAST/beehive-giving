class ChangeFeedbackOtherType < ActiveRecord::Migration
  def up
    change_column :feedbacks, :other, :text
  end

  def down
    change_column :feedbacks, :other, :string
  end
end
