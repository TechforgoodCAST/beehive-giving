class AddStateToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :state, :string, default: 'initial', required: true
    add_index :proposals, :state
    add_column :proposals, :affect_people, :boolean, required: true
    add_column :proposals, :affect_other, :boolean, required: true
    add_column :proposals, :affect_geo, :integer, required: true
    add_column :proposals, :total_costs_estimated, :boolean, required: true
    add_column :proposals, :funding_type, :string, required: true

    create_table :age_groups_proposals do |t|
      t.references :age_group
      t.references :proposal
    end

    add_index :age_groups_proposals, [:age_group_id, :proposal_id]
  end
end
