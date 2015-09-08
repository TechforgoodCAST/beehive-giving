class AddAuthorisedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authorised, :bool
    # TODO: make all existing users authorised. default to true.
  end
end
