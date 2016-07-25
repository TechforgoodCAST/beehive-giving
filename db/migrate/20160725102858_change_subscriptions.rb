class ChangeSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :strip_user_id, :string
    add_column :subscriptions, :active, :boolean, null: false, default: false
    add_index :subscriptions, :strip_user_id, unique: true
    remove_column :subscriptions, :plan_id, :integer

    drop_table :plans do |t|
      t.string :name
      t.float :price
      t.string :interval
      t.text :features
      t.boolean :highlight
      t.integer :display_order

      t.timestamps null: false
    end
  end
end
