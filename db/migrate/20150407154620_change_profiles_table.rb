class ChangeProfilesTable < ActiveRecord::Migration
  def up
    create_table :implementors do |t|
      t.string :label

      t.timestamps null: false
    end

    create_table :implementors_profiles do |t|
      t.references :implementor
      t.references :profile
    end

    remove_column :profiles, :goods_services
    remove_column :profiles, :who_pays
    remove_column :profiles, :who_buys

    add_column :profiles, :does_sell, :boolean
  end

  def down
    drop_table :implementors
    drop_table :implementors_profiles

    add_column :profiles, :goods_services, :string
    add_column :profiles, :who_pays, :string
    add_column :profiles, :who_buys, :string

    remove_column :profiles, :does_sell
  end
end
