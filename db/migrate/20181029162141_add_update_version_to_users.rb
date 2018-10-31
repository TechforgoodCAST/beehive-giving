class AddUpdateVersionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :update_version, :datetime
  end
end
