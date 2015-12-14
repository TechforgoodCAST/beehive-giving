class CreateProposals < ActiveRecord::Migration

  def change
    create_table :proposals do |t|
      t.references :recipient, index: true
      t.string :title, :tagline, :gender, :outcome1, required: true
      t.string :outcome2, :outcome3, :outcome4, :outcome5, :beneficiaries_other
      t.integer :min_age, :max_age, :beneficiaries_count, :funding_duration, required: true
      t.float :activity_costs, :people_costs, :capital_costs, :other_costs, :total_costs, required: true
      t.boolean :activity_costs_estimated, :people_costs_estimated, :capital_costs_estimated, :other_costs_estimated
      t.boolean :all_funding_required, required: true
      t.boolean :beneficiaries_other_required

      t.timestamps null: false
    end

    create_table :beneficiaries_proposals do |t|
      t.references :beneficiary, index: true
      t.references :proposal, index: true
    end

    create_table :countries_proposals do |t|
      t.references :country, index: true
      t.references :proposal, index: true
    end

    create_table :districts_proposals do |t|
      t.references :district, index: true
      t.references :proposal, index: true
    end

    add_column :recommendations, :grant_amount_recommendation, :float, default: 0
    add_column :recommendations, :grant_duration_recommendation, :float, default: 0
    add_column :recommendations, :total_recommendation, :float, default: 0
    change_column_default(:recommendations, :score, 0)
  end

end
