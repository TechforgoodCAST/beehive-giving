class AddOpportunitiesLastUpdatedAtToCollections < ActiveRecord::Migration[5.1]
  def change
    add_column :funders, :opportunities_last_updated_at, :datetime, default: Date.new(2018, 10, 31), null: false
    add_column :themes, :opportunities_last_updated_at, :datetime, default: Date.new(2018, 10, 31), null: false

    remove_column :assessments, :fund_version, :bigint
  end
end
