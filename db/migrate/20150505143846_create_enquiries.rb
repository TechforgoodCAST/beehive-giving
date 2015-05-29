class CreateEnquiries < ActiveRecord::Migration
  def change
    create_table :enquiries do |t|
      t.references :recipient
      t.references :funder
      t.boolean :new_project
      t.boolean :new_location
      t.integer :amount_seeking
      t.integer :duration_seeking

      t.timestamps null:false
    end

    create_table :countries_enquiries do |t|
      t.references :enquiry
      t.references :country
    end

    create_table :districts_enquiries do |t|
      t.references :enquiry
      t.references :district
    end
  end
end
