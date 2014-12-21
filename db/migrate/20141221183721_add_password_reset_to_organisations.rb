class AddPasswordResetToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :password_reset_token, :string
    add_column :organisations, :password_reset_sent_at, :datetime
  end
end
