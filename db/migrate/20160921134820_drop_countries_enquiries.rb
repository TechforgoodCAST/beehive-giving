class DropCountriesEnquiries < ActiveRecord::Migration
  def change
    drop_table :countries_enquiries do |t|
      t.references :enquiry
      t.references :country
    end

    drop_table :districts_enquiries do |t|
      t.references :enquiry
      t.references :district
    end
  end
end
