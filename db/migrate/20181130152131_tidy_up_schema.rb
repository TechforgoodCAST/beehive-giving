class TidyUpSchema < ActiveRecord::Migration[5.1]
  def change
    drop_table :attempts
    drop_table :enquiries
    drop_table :feedbacks
    drop_table :requests

    remove_column :recipients, :contact_number, :string
    remove_column :recipients, :street_address, :string
    remove_column :recipients, :city, :string
    remove_column :recipients, :region, :string
    remove_column :recipients, :postal_code, :string
    remove_column :recipients, :country_alpha2, :string
    remove_column :recipients, :mission, :text
    remove_column :recipients, :founded_on, :date
    remove_column :recipients, :registered_on, :date
    remove_column :recipients, :registered, :boolean
    remove_column :recipients, :active_on_beehive, :boolean
    remove_column :recipients, :org_type, :boolean
    remove_column :recipients, :latitude, :float
    remove_column :recipients, :longitude, :float
    remove_column :recipients, :contact_email, :string
    remove_column :recipients, :charity_name, :string
    remove_column :recipients, :charity_status, :string
    remove_column :recipients, :charity_income, :float
    remove_column :recipients, :charity_spending, :float
    remove_column :recipients, :charity_recent_accounts_link, :string
    remove_column :recipients, :charity_trustees, :string
    remove_column :recipients, :charity_employees, :string
    remove_column :recipients, :charity_volunteers, :string
    remove_column :recipients, :charity_year_ending, :string
    remove_column :recipients, :charity_days_overdue, :string
    remove_column :recipients, :charity_registered_date, :string
    remove_column :recipients, :company_name, :string
    remove_column :recipients, :company_type, :string
    remove_column :recipients, :company_status, :string
    remove_column :recipients, :company_incorporated_date, :date
    remove_column :recipients, :company_last_accounts_date, :date
    remove_column :recipients, :company_next_accounts_date, :date
    remove_column :recipients, :company_next_returns_date, :date
    remove_column :recipients, :company_last_returns_date, :date
    remove_column :recipients, :company_sic, :text
    remove_column :recipients, :company_recent_accounts_link, :string
    remove_column :recipients, :grants_count, :integer
    remove_column :recipients, :multi_national, :boolean
    remove_column :recipients, :employees, :integer
    remove_column :recipients, :volunteers, :integer
    remove_column :recipients, :funds_checked, :integer
    remove_column :recipients, :income, :integer
  end
end
