class AddSlugToOrganisations < ActiveRecord::Migration
  def change
    # add_column :organisations, :slug, :string
    add_index :oranisations, :slug, unique: true
  end
end
