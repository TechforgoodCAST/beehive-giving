class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.references :funder, required: true
      t.references :recipient, required: true
      t.float :score, default: 0

      t.timestamps null: false
    end

    create_table :beneficiaries_funder_attributes do |t|
      t.references :funder_attribute, required: true
      t.references :beneficiary, required: true

      t.timestamps null: false
    end

    create_table :districts_funder_attributes do |t|
      t.references :funder_attribute, required: true
      t.references :district, required: true

      t.timestamps null: false
    end

    add_column :funder_attributes, :beneficiary_min_age, :integer
    add_column :funder_attributes, :beneficiary_max_age, :integer
  end
end
