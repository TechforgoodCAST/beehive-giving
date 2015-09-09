class AddAuthorisedToUsers < ActiveRecord::Migration
  def up
    add_column :users, :authorised, :boolean, :default => true
  end

  def down
    remove_column :users, :authorised
  end
end
