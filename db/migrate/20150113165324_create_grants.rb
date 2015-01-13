class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.string :funding_stream, :type,  required: true
      t.string :attention_how
      t.integer :amount_awarded,  required: true
      t.integer :amount_applied, :installments
      t.date :approved_on, :start_on, :end_on, required: true
      t.date :attention_on, :applied_on

      t.timestamps null: false
    end

    create_table :grants_organisations do |t|
      t.references :grant
      t.references :organisation
    end
  end
end
