class AddStateToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :state, :string
    add_index :profiles, :state
  end
end
