class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.references :funder
      t.references :organisation
      t.string :funding_stream, :grant_type,  required: true
      t.string :attention_how
      t.integer :amount_awarded,  required: true
      t.integer :amount_applied, :installments
      t.date :approved_on, :start_on, :end_on, required: true
      t.date :attention_on, :applied_on

      t.timestamps null: false
    end
  end
end
