class AddSpecificDataRequestsToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :request_amount_awarded, :boolean
    add_column :features, :request_funding_dates, :boolean
    add_column :features, :request_funding_countries, :boolean
  end
end
