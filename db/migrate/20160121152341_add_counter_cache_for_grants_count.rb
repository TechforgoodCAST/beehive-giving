class AddCounterCacheForGrantsCount < ActiveRecord::Migration
  def change
    add_column :organisations, :grants_count, :integer, default: 0
  end
end
