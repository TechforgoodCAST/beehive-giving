class AddFunderUnlocksCountToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :recipient_funder_accesses_count, :integer
  end
end
