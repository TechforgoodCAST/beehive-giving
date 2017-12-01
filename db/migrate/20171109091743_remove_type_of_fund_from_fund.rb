class RemoveTypeOfFundFromFund < ActiveRecord::Migration[5.1]
  def change
    remove_column :funds, :type_of_fund, :string
  end
end
