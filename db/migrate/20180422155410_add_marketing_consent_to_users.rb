class AddMarketingConsentToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :marketing_consent, :boolean
  end
end
