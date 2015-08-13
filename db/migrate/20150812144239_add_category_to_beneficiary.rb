class AddCategoryToBeneficiary < ActiveRecord::Migration
  def change
    add_column :beneficiaries, :category, :string
    add_column :beneficiaries, :sort, :string
  end
end
