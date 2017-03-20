class AddDiscountAndExpiryDateToSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :expiry_date, :date
    add_column :subscriptions, :percent_off, :integer, null: false, default: 0
  end
end
