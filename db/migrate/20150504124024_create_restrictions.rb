class CreateRestrictions < ActiveRecord::Migration
  def change
    create_table :restrictions do |t|
      t.references :funder
      t.string :details

      t.timestamps null: false
    end
  end
end
