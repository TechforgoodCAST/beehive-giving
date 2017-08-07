class DropProfiles < ActiveRecord::Migration[5.1]
  def change
    drop_table :profiles
    drop_table :age_groups_profiles
    drop_table :beneficiaries_profiles
    drop_table :countries_profiles
    drop_table :districts_profiles
    drop_table :implementations_profiles
    drop_table :implementors_profiles
    drop_table :implementors
  end
end
