class AddInsightsToFunderAttributes < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :approval_months_by_count, :text
    add_column :funder_attributes, :approval_months_by_giving, :string
    add_column :funder_attributes, :countries_by_count, :string
    add_column :funder_attributes, :countries_by_giving, :string
    add_column :funder_attributes, :regions_by_count, :string
    add_column :funder_attributes, :regions_by_giving, :string
    add_column :funder_attributes, :funding_streams_by_count, :string
    add_column :funder_attributes, :funding_streams_by_giving, :string
  end
end
