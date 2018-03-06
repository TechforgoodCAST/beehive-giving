class AddPrettyNameToFunds < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :pretty_name, :string
  end
end
