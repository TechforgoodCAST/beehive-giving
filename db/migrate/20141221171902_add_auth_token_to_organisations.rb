class AddAuthTokenToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :auth_token, :string
  end
end
