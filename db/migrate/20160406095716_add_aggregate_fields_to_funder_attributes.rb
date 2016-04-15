class AddAggregateFieldsToFunderAttributes < ActiveRecord::Migration
  def change

    create_table :age_groups_funder_attributes do |t|
      t.references :age_group
      t.references :funder_attribute
    end

    add_index :age_groups_funder_attributes, [:age_group_id, :funder_attribute_id], :name => 'index_age_groups_funder_attributes'

    add_column :recommendations, :org_type_score, :float
    add_column :recommendations, :beneficiary_score, :float
    add_column :recommendations, :location_score, :float
    add_column :recommendations, :funding_amount_score, :float
    add_column :recommendations, :funding_duration_score, :float

  end
end
