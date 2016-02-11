class AddMapDataToFunderAttribute < ActiveRecord::Migration
  def change
    add_column :funder_attributes, :map_data, :text
    add_column :funder_attributes, :shared_recipient_ids, :text
    add_column :funder_attributes, :no_of_recipients_funded, :integer
    add_column :districts, :slug, :string
    add_column :districts, :indices_year, :string
    add_column :districts, :indices_rank, :integer
    add_column :districts, :indices_rank_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_income_rank, :integer
    add_column :districts, :indices_income_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_employment_rank, :integer
    add_column :districts, :indices_employment_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_education_rank, :integer
    add_column :districts, :indices_education_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_health_rank, :integer
    add_column :districts, :indices_health_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_crime_rank, :integer
    add_column :districts, :indices_crime_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_barriers_rank, :integer
    add_column :districts, :indices_barriers_proportion_most_deprived_ten_percent, :float
    add_column :districts, :indices_living_rank, :integer
    add_column :districts, :indices_living_proportion_most_deprived_ten_percent, :float
  end
end
