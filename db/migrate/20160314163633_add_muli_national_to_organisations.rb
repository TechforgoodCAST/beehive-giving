class AddMuliNationalToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :multi_national, :boolean
  end
end
