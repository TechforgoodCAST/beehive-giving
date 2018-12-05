class CreateVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes do |t|
      t.references :assessment, foreign_key: true
      t.string :relationship_to_assessment
      t.string :relationship_details
      t.boolean :agree_with_rating
      t.text :reason

      t.timestamps
    end
  end
end
