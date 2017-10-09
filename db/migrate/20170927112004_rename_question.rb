class RenameQuestion < ActiveRecord::Migration[5.1]
  def change
    rename_table :questions, :criteria
  end
end
