class AddStaticDataToFunderAttributes < ActiveRecord::Migration
  def up
    create_table :countries_funder_attributes do |t|
      t.references :funder_attribute
      t.references :country
    end

    create_table :funding_types do |t|
      t.string :label
    end

    create_table :funder_attributes_funding_types do |t|
      t.references :funder_attribute
      t.references :funding_type
    end

    %w[Unrestricted].each do |state|
      FundingType.create(label:state)
    end

    create_table :funding_streams do |t|
      t.string :label
    end

    %w[All Main].each do |state|
      FundingStream.create(label:state)
    end

    create_table :approval_months do |t|
      t.string :month
    end

    create_table :approval_months_funder_attributes do |t|
      t.references :funder_attribute
      t.references :approval_month
    end

    %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].each do |state|
      ApprovalMonth.create(month:state)
    end

    add_reference :funder_attributes, :funding_stream, index: true

    rename_column :funder_attributes, :year, :period
    change_column :funder_attributes, :period, :string

    add_column :funder_attributes, :funding_size_average, :decimal
    add_column :funder_attributes, :funding_size_min, :decimal
    add_column :funder_attributes, :funding_size_max, :decimal
    add_column :funder_attributes, :funding_duration_average, :decimal
    add_column :funder_attributes, :funding_duration_min, :decimal
    add_column :funder_attributes, :funding_duration_max, :decimal

    add_column :funder_attributes, :funded_average_age, :decimal
    add_column :funder_attributes, :funded_average_income, :decimal
    add_column :funder_attributes, :funded_average_paid_staff, :decimal

    remove_column :funder_attributes, :non_financial_support
  end

  def down
    drop_table :countries_funder_attributes
    drop_table :funding_types
    drop_table :funder_attributes_funding_types
    drop_table :funding_streams
    drop_table :approval_months
    drop_table :approval_months_funder_attributes

    remove_column :funder_attributes, :funding_stream_id

    rename_column :funder_attributes, :period, :year
    change_column :funder_attributes, :year, 'integer USING CAST(year AS integer)'

    remove_column :funder_attributes, :funding_size_average
    remove_column :funder_attributes, :funding_size_min

    remove_column :funder_attributes, :funding_size_max
    remove_column :funder_attributes, :funding_duration_average
    remove_column :funder_attributes, :funding_duration_min
    remove_column :funder_attributes, :funding_duration_max

    remove_column :funder_attributes, :funded_average_age
    remove_column :funder_attributes, :funded_average_income
    remove_column :funder_attributes, :funded_average_paid_staff

    add_column :funder_attributes, :non_financial_support, :string
  end
end
