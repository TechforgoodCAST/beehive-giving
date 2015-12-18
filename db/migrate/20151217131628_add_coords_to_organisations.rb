class AddCoordsToOrganisations < ActiveRecord::Migration
  def change
    add_column :users, :seeking, :integer, required: true

    add_column :organisations, :org_type, :string, required: true
    add_column :organisations, :latitude, :float
    add_column :organisations, :longitude, :float
    add_column :organisations, :contact_email, :string
    add_column :organisations, :charity_name, :string
    add_column :organisations, :charity_status, :string
    add_column :organisations, :charity_income, :float
    add_column :organisations, :charity_spending, :float
    add_column :organisations, :charity_recent_accounts_link, :string
    add_column :organisations, :charity_trustees, :string
    add_column :organisations, :charity_employees, :string
    add_column :organisations, :charity_volunteers, :string
    add_column :organisations, :charity_year_ending, :string
    add_column :organisations, :charity_days_overdue, :string
    add_column :organisations, :charity_registered_date, :string
    add_column :organisations, :company_name, :string
    add_column :organisations, :company_type, :string
    add_column :organisations, :company_status, :string
    add_column :organisations, :company_incorporated_date, :date
    add_column :organisations, :company_last_accounts_date, :date
    add_column :organisations, :company_next_accounts_date, :date
    add_column :organisations, :company_accounts_due_date, :date
    add_column :organisations, :company_next_annual_return_date, :date
    add_column :organisations, :company_last_annual_return_date, :date
    add_column :organisations, :company_annual_return_due_date, :date
    add_column :organisations, :company_sic, :text, array: true
    add_column :organisations, :company_recent_accounts_link, :string
  end
end
