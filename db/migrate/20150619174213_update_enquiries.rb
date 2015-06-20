class UpdateEnquiries < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :guidance_link, :string
    add_column :funder_attributes, :application_link, :string
    add_column :funder_attributes, :application_details, :string
    add_column :funder_attributes, :soft_restrictions, :text
    add_column :enquiries, :approach_funder_count, :integer
    add_column :enquiries, :guidance_count, :integer
    add_column :enquiries, :apply_count, :integer
    add_column :recommendations, :recommendation_quality, :string
  end
end
