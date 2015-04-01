class AddDaysFromColumnsToGrant < ActiveRecord::Migration
  def change
    add_column :grants, :days_from_attention_to_applied, :integer
    add_column :grants, :days_from_applied_to_approved, :integer
    add_column :grants, :days_form_approval_to_start, :integer
    add_column :grants, :days_from_start_to_end, :integer
  end
end
