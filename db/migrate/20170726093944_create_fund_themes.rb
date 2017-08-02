class CreateFundThemes < ActiveRecord::Migration[5.1]
  def change
    create_table :fund_themes do |t|
      t.references :fund, foreign_key: true
      t.references :theme, foreign_key: true

      t.timestamps
    end
  end
end
