class AddTogglesToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :affect_people, :boolean
    add_column :profiles, :affect_other, :boolean

    create_table :age_groups do |t|
      t.string :label
      t.integer :age_from
      t.integer :age_to
      t.timestamps null: false
    end

    create_table :age_groups_profiles do |t|
      t.references :age_group
      t.references :profile
    end

    add_index :age_groups_profiles, [:age_group_id, :profile_id]
  end
end
