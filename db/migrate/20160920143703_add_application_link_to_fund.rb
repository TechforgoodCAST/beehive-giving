class AddApplicationLinkToFund < ActiveRecord::Migration
  def change
    add_column :funds, :application_link, :string, required: true
    remove_column :funds, :key_criteria_known, :boolean
  end
end
