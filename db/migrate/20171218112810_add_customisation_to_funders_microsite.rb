class AddCustomisationToFundersMicrosite < ActiveRecord::Migration[5.1]
  def change
    add_column :funders, :primary_colour, :string
    add_column :funders, :headline_colour, :string
    add_column :funders, :subtitle_colour, :string
  end
end
