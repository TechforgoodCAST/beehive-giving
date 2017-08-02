class CreateProposalThemes < ActiveRecord::Migration[5.1]
  def change
    create_table :proposal_themes do |t|
      t.references :proposal, foreign_key: true
      t.references :theme, foreign_key: true

      t.timestamps
    end
  end
end
