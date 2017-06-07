class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false

      t.timestamps null: false
    end

    add_index :articles, :slug, unique: true
  end
end
