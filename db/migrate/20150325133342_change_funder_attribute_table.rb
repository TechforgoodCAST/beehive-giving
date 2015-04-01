class ChangeFunderAttributeTable < ActiveRecord::Migration
  def up
    add_column :funder_attributes, :year, :integer
    add_column :funder_attributes, :grant_count, :integer
    add_column :funder_attributes, :application_count, :integer
    add_column :funder_attributes, :enquiry_count, :integer
    add_column :funder_attributes, :non_financial_support, :string

    remove_column :funder_attributes, :funding_type
    remove_column :funder_attributes, :next_deadline
    remove_column :funder_attributes, :application_process
    remove_column :funder_attributes, :funding_round_frequency
    remove_column :funder_attributes, :funding_streams

    create_table :application_processes do |t|
      t.string :label

      t.timestamps null: false
    end

    create_table :application_supports do |t|
      t.string :label

      t.timestamps null: false
    end

    create_table :reporting_requirements do |t|
      t.string :label

      t.timestamps null: false
    end

    create_table :application_processes_funder_attributes do |t|
      t.references :funder_attribute
      t.references :application_process
    end

    create_table :application_supports_funder_attributes do |t|
      t.references :funder_attribute
      t.references :application_support
    end

    create_table :funder_attributes_reporting_requirements do |t|
      t.references :funder_attribute
      t.references :reporting_requirement
    end
  end

  def down
    remove_column :funder_attributes, :year
    remove_column :funder_attributes, :grant_count
    remove_column :funder_attributes, :application_count
    remove_column :funder_attributes, :enquiry_count
    remove_column :funder_attributes, :non_financial_support

    add_column :funder_attributes, :funding_type, :integer
    add_column :funder_attributes, :next_deadline, :date
    add_column :funder_attributes, :application_process, :integer
    add_column :funder_attributes, :funding_round_frequency, :integer
    add_column :funder_attributes, :funding_streams, :integer

    drop_table :application_processes
    drop_table :application_supports
    drop_table :reporting_requirements
    drop_table :application_processes_funder_attributes
    drop_table :application_supports_funder_attributes
    drop_table :funder_attributes_reporting_requirements
  end
end
