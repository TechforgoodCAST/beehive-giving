class RenameUserEmailToEmail < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :user_email, :email
  end
end
