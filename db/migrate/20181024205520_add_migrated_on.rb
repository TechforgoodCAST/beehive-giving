class AddMigratedOn < ActiveRecord::Migration[5.1]
  def change
    add_column :proposals, :duplicate_of, :bigint
    add_column :proposals, :migrated_on, :datetime
    add_column :recipients, :duplicate_of, :bigint
    add_column :recipients, :migrated_on, :datetime
  end
end
