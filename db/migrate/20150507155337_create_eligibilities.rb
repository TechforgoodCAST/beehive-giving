class CreateEligibilities < ActiveRecord::Migration
  def change
    create_table :eligibilities do |t|
      t.references :recipient
      t.references :restriction
      t.boolean :eligible

      t.timestamps null: false
    end

    create_table :organisations_restrictions do |t|
      t.references :funder
      t.references :restriction

      t.timestamps null: false
    end

    remove_reference :restrictions, :funder
  end
end
