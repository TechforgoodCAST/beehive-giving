class CreateRecipientFunderAccesses < ActiveRecord::Migration
  def change
    create_table :recipient_funder_accesses do |t|
      t.integer :recipient_id
      t.integer :funder_id

      t.timestamps
    end
  end
end
