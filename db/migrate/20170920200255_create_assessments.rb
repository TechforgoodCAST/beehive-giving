class CreateAssessments < ActiveRecord::Migration[5.1]
  def change
    create_table :assessments do |t|
      t.references :funder, foreign_key: true
      t.references :recipient, foreign_key: true
      t.references :proposal, foreign_key: true
      t.string :state, null: false, default: 'basics'

      t.timestamps
    end
  end
end
