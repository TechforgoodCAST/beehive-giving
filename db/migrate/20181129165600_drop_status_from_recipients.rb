class DropStatusFromRecipients < ActiveRecord::Migration[5.1]
  def change
    remove_column :recipients, :status, :string
  end
end
