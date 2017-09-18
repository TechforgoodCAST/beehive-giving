class CreateFunders < ActiveRecord::Migration[5.1]
  def change
    rename_table :organisations, :recipients
    rename_column :subscriptions, :organisation_id, :recipient_id

    create_table :funders do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :website
      t.string :charity_number
      t.string :company_number
      t.boolean :active, default: false

      t.index :slug, unique: true

      t.timestamps
    end

    rename_column :recipients, :type, :type_temp
  end
end
