class AddAggregateFieldsToFunderAttributes < ActiveRecord::Migration
  def change

    create_table :age_groups_funder_attributes do |t|
      t.references :age_group
      t.references :funder_attribute
    end

    add_index :age_groups_funder_attributes, [:age_group_id, :funder_attribute_id], name: 'index_age_groups_funder_attributes'

    create_table :implementations_proposals do |t|
      t.references :implementation
      t.references :proposal
    end

    add_index :implementations_proposals, [:implementation_id, :proposal_id], name: 'index_implementations_proposals'

    add_column :recommendations, :org_type_score, :float
    add_column :recommendations, :beneficiary_score, :float
    add_column :recommendations, :location_score, :float

    add_column :proposals, :private, :boolean, required: true
    add_column :proposals, :implementations_other_required, :boolean
    add_column :proposals, :implementations_other, :string

  end
end
