class AddVersionToSubscription < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :version, :integer, null: false, default: 1
    add_column :recipients, :reveals, :jsonb, null: false, default: []
  end
end
