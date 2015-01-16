class AddTypeToOrgs < ActiveRecord::Migration
  def change
    add_column :organisations, :type, :string
    remove_column :organisations, :organisation_type
  end
end
