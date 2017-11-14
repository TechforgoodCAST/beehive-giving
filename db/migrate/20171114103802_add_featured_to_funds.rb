class AddFeaturedToFunds < ActiveRecord::Migration[5.1]
  def change
    add_column :funds, :featured, :boolean, default: false
  end
end
