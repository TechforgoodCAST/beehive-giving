class CreateThemes < ActiveRecord::Migration[5.1]
  def change
    create_table :themes do |t|
      t.string :name, null: false
      t.integer :parent_id
      t.jsonb :related, default: {}, null: false

      t.timestamps
    end

    add_index :themes, :name, unique: true
    add_index :themes, :parent_id
  end
end
