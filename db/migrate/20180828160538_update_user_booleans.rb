class UpdateUserBooleans < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :terms_agreed, :timestamp
  end
end
