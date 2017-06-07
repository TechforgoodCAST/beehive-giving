class DeprecateFundersPlatform < ActiveRecord::Migration[5.0]
  def change
    drop_table :approval_months

    drop_table :funder_attributes
    drop_table :age_groups_funder_attributes
    drop_table :approval_months_funder_attributes
    drop_table :beneficiaries_funder_attributes
    drop_table :countries_funder_attributes
    drop_table :districts_funder_attributes
    drop_table :funder_attributes_funding_types

    drop_table :grants
    drop_table :countries_grants
    drop_table :districts_grants

    drop_table :funding_streams
    drop_table :funding_streams_organisations
    drop_table :funding_streams_restrictions

    remove_column :districts, :geometry
    remove_column :districts, :indices_year
    remove_column :districts, :indices_rank
    remove_column :districts, :indices_rank_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_income_rank
    remove_column :districts, :indices_income_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_employment_rank
    remove_column :districts, :indices_employment_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_education_rank
    remove_column :districts, :indices_education_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_health_rank
    remove_column :districts, :indices_health_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_crime_rank
    remove_column :districts, :indices_crime_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_barriers_rank
    remove_column :districts, :indices_barriers_proportion_most_deprived_ten_percent
    remove_column :districts, :indices_living_rank
    remove_column :districts, :indices_living_proportion_most_deprived_ten_percent
  end
end
