class AddUnlockTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :unlock_token, :string
  end

  def down
    remove_column :users, :unlock_token
  end
end
