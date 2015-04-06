class AddOpenCallToGrants < ActiveRecord::Migration
  def change
    drop_table :application_processes
    drop_table :application_processes_funder_attributes

    add_column :grants, :open_call, :boolean
  end
end
