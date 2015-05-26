class CreateRecipientAttributes < ActiveRecord::Migration
  def change
    create_table :recipient_attributes do |t|
      t.references :recipient
      t.text :problem
      t.text :solution

      t.timestamps null: false
    end

    add_index :recipient_attributes, :recipient_id
  end
end
