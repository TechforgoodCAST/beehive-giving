class AddSlugToThemes < ActiveRecord::Migration[5.1]
  def up
    add_column :themes, :slug, :string
    add_index :themes, :slug, unique: true
    Theme.all.each do |t|
      t.update_attribute(:slug, t.name.parameterize)
    end
  end

  def down
    remove_column :themes, :slug
  end
end
