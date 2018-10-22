class RenameColourToColor < ActiveRecord::Migration[5.1]
  def change
    rename_column :funders, :primary_colour, :primary_color
    rename_column :funders, :headline_colour, :secondary_color
    remove_column :funders, :subtitle_colour, :string
  end
end
