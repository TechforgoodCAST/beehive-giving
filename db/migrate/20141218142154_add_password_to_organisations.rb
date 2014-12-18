class AddPasswordToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :password_digest, :string
  end
end
