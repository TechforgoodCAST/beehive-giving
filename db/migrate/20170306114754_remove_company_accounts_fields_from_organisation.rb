class RemoveCompanyAccountsFieldsFromOrganisation < ActiveRecord::Migration[5.0]
  def change
    remove_column :organisations, :company_accounts_due_date, :date
    remove_column :organisations, :company_annual_return_due_date, :date
    rename_column :organisations, :company_next_annual_return_date, :company_next_returns_date
    rename_column :organisations, :company_last_annual_return_date, :company_last_returns_date
  end
end
