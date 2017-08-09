class DropRecommendations < ActiveRecord::Migration[5.1]
  def change
    drop_table :recommendations
  end
end
