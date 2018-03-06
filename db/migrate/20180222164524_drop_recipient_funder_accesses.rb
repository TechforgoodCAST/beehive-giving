class DropRecipientFunderAccesses < ActiveRecord::Migration[5.1]
  def change
    drop_table :recipient_funder_accesses
    remove_column :recipients, :recipient_funder_accesses_count
  end
end
