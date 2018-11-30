class RemoveMicrositeColumnFromFunders < ActiveRecord::Migration[5.1]
  def change
    remove_column :funders, :microsite, :boolean
  end
end
