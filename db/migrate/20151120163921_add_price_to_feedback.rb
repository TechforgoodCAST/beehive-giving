class AddPriceToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :price, :integer
  end
end
