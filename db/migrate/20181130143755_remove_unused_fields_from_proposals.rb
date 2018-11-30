class RemoveUnusedFieldsFromProposals < ActiveRecord::Migration[5.1]
  def change
    remove_column :proposals, :gender, :string
    remove_column :proposals, :outcome1, :string
    remove_column :proposals, :outcome2, :string
    remove_column :proposals, :outcome3, :string
    remove_column :proposals, :outcome4, :string
    remove_column :proposals, :outcome5, :string
    remove_column :proposals, :beneficiaries_other, :string
    remove_column :proposals, :min_age, :integer
    remove_column :proposals, :max_age, :integer
    remove_column :proposals, :beneficiaries_count, :integer
    remove_column :proposals, :activity_costs, :float
    remove_column :proposals, :people_costs, :float
    remove_column :proposals, :capital_costs, :float
    remove_column :proposals, :other_costs, :float
    remove_column :proposals, :activity_costs_estimated, :boolean
    remove_column :proposals, :people_costs_estimated, :boolean
    remove_column :proposals, :capital_costs_estimated, :boolean
    remove_column :proposals, :other_costs_estimated, :boolean
    remove_column :proposals, :all_funding_required, :boolean
    remove_column :proposals, :beneficiaries_other_required, :boolean
    remove_column :proposals, :type_of_support, :string
    remove_column :proposals, :affect_people, :boolean
    remove_column :proposals, :affect_other, :boolean
    remove_column :proposals, :affect_geo, :integer
    remove_column :proposals, :total_costs_estimated, :boolean
    remove_column :proposals, :implementations_other_required, :boolean
    remove_column :proposals, :implementations_other, :string
    remove_column :proposals, :recommended_funds, :jsonb
    remove_column :proposals, :eligibility, :jsonb
    remove_column :proposals, :suitability, :jsonb
    remove_column :proposals, :legacy, :boolean

    drop_table :age_groups_proposals
    drop_table :age_groups
    drop_table :beneficiaries_proposals
    drop_table :beneficiaries
    drop_table :implementations_proposals
    drop_table :implementations
  end
end
