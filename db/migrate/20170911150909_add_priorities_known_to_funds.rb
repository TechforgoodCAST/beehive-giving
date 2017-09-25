class AddPrioritiesKnownToFunds < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :priorities_known, :boolean
  end
end
