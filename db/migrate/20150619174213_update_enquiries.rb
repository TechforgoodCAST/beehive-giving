class UpdateEnquiries < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :application_link, :string
    add_column :funder_attributes, :application_details, :string
    add_column :funder_attributes, :soft_restrictions, :text
    add_column :enquiries, :approach_funder_count, :integer
    add_column :enquiries, :funding_stream, :string
    add_column :recommendations, :recommendation_quality, :string
  end
end
