class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :user, required: true
      t.integer :nps, :taken_away, :decision_control, required: true
      t.string :other

      t.timestamps null: false
    end
  end
end
