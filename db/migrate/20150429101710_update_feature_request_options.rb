class UpdateFeatureRequestOptions < ActiveRecord::Migration
  def change
    add_column :features, :request_grant_count, :boolean
    add_column :features, :request_applications_count, :boolean
    add_column :features, :request_enquiry_count, :boolean
    add_column :features, :request_funding_types, :boolean
    add_column :features, :request_funding_streams, :boolean
    add_column :features, :request_approval_months, :boolean
  end
end
