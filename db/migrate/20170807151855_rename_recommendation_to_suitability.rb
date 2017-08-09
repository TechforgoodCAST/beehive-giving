class RenameRecommendationToSuitability < ActiveRecord::Migration[5.1]
  def change
    rename_column :proposals, :recommendation, :suitability
    disable_extension 'intarray'
  end
end
