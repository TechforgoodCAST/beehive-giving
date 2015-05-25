class CreateFundingStream < ActiveRecord::Migration
  def change
    create_table :funding_streams do |t|
      t.string :label
      t.string :group

      t.timestamps null: false
    end

    create_table :funding_streams_organisations do |t|
      t.references :funder
      t.references :funding_stream

      t.timestamps null: false
    end

    create_table :funding_streams_restrictions do |t|
      t.references :funding_stream
      t.references :restriction

      t.timestamps null: false
    end

    drop_table :organisations_restrictions do |t|
      t.references :funder
      t.references :restriction

      t.timestamps null: false
    end

    remove_column :restrictions, :funding_stream, :string

    drop_table :application_supports do |t|
      t.string :label

      t.timestamps null: false
    end

    drop_table :application_supports_funder_attributes do |t|
      t.references :funder_attribute
      t.references :application_support
    end

    drop_table :reporting_requirements do |t|
      t.string :label

      t.timestamps null: false
    end

    drop_table :funder_attributes_reporting_requirements do |t|
      t.references :funder_attribute
      t.references :reporting_requirement
    end
  end
end
