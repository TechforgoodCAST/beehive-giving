class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name, :contact_name, :contact_role, :contact_email, required: true
      t.string :contact_number, :website, :street_address, :city, :region, :postal_code, :charity_number, :company_number
      t.date :founded_on, :registered_on

      t.timestamps
    end
  end
end
