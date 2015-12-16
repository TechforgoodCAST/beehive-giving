class AddTypeOfSupportToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :type_of_support, :string, required: true
  end
end
