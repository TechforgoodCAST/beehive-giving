class SplitContactName < ActiveRecord::Migration
  def change
    rename_column :organisations, :contact_name, :contact_first_name
    add_column :organisations, :contact_last_name, :string
  end
end
