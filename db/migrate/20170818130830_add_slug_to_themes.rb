class AddSlugToThemes < ActiveRecord::Migration[5.1]
  def change
    add_column :themes, :slug, :string
  end

  def up
    Theme.all.each do |t|
      t.update_attribute(:slug, t.name.parameterize)
    end
  end
end
